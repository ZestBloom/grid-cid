"reach 0.1";
"use strict";
// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [
  Participant("Manager", {
    getParams: Fun(
      [],
      Object({
        app: Bytes(46),
      })
    ),
  }),
  Participant("Relay", {}),
];
export const Views = () => [
  View({
    app: Bytes(46),
    count: UInt,
  }),
];
export const Api = () => [
  API({
    update: Fun([Bytes(46)], Null),
    //destroy: Fun([], Null),
    incr: Fun([], Null),
    reset: Fun([], Null),
  }),
];
export const App = (map) => {
  const [[_, _, addr], [Manager, Relay], [v], [a]] = map;
  Manager.only(() => {
    const { app } = declassify(interact.getParams());
    assume(this == addr);
  });
  Manager.publish(app);
  require(Manager == addr);
  v.app.set(app);
  v.count.set(0);
  Relay.set(Manager);
  const [keepGoing, cid, as] = parallelReduce([true, app, 0])
    .define(() => {
      v.app.set(cid);
      v.count.set(as);
    })
    .invariant(balance() >= 0)
    .while(keepGoing)
    /*
    .api(
      a.destroy,
      () => assume(this === Manager),
      () => 0,
      (k) => {
        require(true);
        k(null);
        return [true, cid, as];
      }
    )
    */
    .api(
      a.update,
      (_) => assume(this == Manager),
      (_) => 0,
      (m, k) => {
        require(this == Manager);
        k(null);
        return [true, m, as];
      }
    )
    .api(
      a.incr,
      () => assume(true),
      () => 0,
      (k) => {
        require(true);
        k(null);
        return [true, cid, as + 1];
      }
    )
    .api(
      a.reset,
      () => assume(this == Manager),
      () => 0,
      (k) => {
        require(this == Manager);
        k(null);
        return [true, cid, 0];
      }
    )
    .timeout(false);
  commit();
  Relay.publish();
  transfer(balance()).to(Relay);
  commit();
  exit();
};
// ----------------------------------------------
