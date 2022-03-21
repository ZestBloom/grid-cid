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
        app: Bytes(32),
      })
    ),
  }),
  Participant("Relay", {})
];
export const Views = () => [
  View({
    app: Bytes(32)
  })
];
export const Api = () => [];
export const App = (map) => {
  const [[Manager, Relay], [v], _] = map;
  Manager.only(() => {
    const { app } = declassify(interact.getParams())
  })
  Manager.publish(app);
  v.app.set(app);
  Relay.set(Manager);
  commit();
  Relay.publish();
  commit();
  exit();
};
// ----------------------------------------------
