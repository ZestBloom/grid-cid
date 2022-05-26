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
  }),
];
export const Api = () => [
  API({
    update: Fun([Bytes(46)], Null),
    destroy: Fun([], Null)
  })
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
  Relay.set(Manager);
  const [keepGoing, cid] = parallelReduce([true, app])
  .define(() => {
    v.app.set(cid);
  })
  .invariant(balance() >= 0)
  .while(keepGoing)
  .api(a.destroy,
    () => assume(true),
    () => 0,
    (k) => {
      require(true);
      k(null);
      return [false, cid];
    })
    .api(a.update,
      (_) => assume(true),
      (_) => 0,
      (m, k) => {
        require(true);
        k(null);
        return [true, m];
      })
  .timeout(false);
  commit();
  Relay.publish();
  transfer(balance()).to(Relay);
  commit();
  exit();
};
// ----------------------------------------------
