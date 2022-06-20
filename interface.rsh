"reach 0.1";
"use strict";
// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Event = () => [];
export const Participants = () => [
  Participant("Manager", {
    getParams: Fun(
      [],
      Object({
        app: Bytes(46), // cidv0
      })
    ),
  })
];
export const Views = () => [
  View({
    manager: Address,
    app: Bytes(46),
    count: UInt,
  }),
];
export const Api = () => [
  API({
    update: Fun([Bytes(46)], Null),
    incr: Fun([], Null),
    reset: Fun([], Null),
    grant: Fun([Address], Null),
  }),
];
export const App = (map) => {
  const [{ amt, ttl }, [addr, _], [Manager], [v], [a], _] = map;
  Manager.only(() => {
    const { app } = declassify(interact.getParams());
    assume(true);
  });
  Manager.publish(app)
    .pay(amt)
    .timeout(relativeTime(ttl), () => {
      Anybody.publish();
      commit();
      exit();
    });
  require(true);
  transfer(amt).to(addr);
  v.manager.set(Manager);
  v.app.set(app);
  v.count.set(0);
  const [keepGoing, cid, as, man] = parallelReduce([true, app, 0, Manager])
    .define(() => {
      v.manager.set(man);
      v.app.set(cid);
      v.count.set(as);
    })
    .invariant(balance() >= 0)
    .while(keepGoing)
    .api(
      a.grant,
      (_) => assume(this == man),
      (_) => 0,
      (m, k) => {
        require(this == man);
        k(null);
        return [true, cid, as, m];
      }
    )
    .api(
      a.update,
      (_) => assume(this == man),
      (_) => 0,
      (m, k) => {
        require(this == man);
        k(null);
        return [true, m, as, man];
      }
    )
    .api(
      a.incr,
      () => assume(true),
      () => 0,
      (k) => {
        require(true);
        k(null);
        return [true, cid, as + 1, man];
      }
    )
    .api(
      a.reset,
      () => assume(this == man),
      () => 0,
      (k) => {
        require(this == man);
        k(null);
        return [true, cid, 0, man];
      }
    )
    .timeout(false);
  commit();
  // Impossible
  Anybody.publish();
  transfer(balance()).to(addr);
  commit();
  exit();
};
// ----------------------------------------------
