// Placement points for top 1..8
const PTS = [10, 8, 7, 6, 4, 3, 2, 1];

// teams: [[nameA, nameB], x4]   places: {name: placement 1..8}
function settle(teams, places) {
  const T = teams.map(t => ({
    t,
    s: t.reduce((a, n) => a + PTS[places[n] - 1], 0),
    b: Math.min(...t.map(n => places[n])),
  }));
  // higher score wins; on a tie the team with the better single placement wins
  T.sort((x, y) => y.s - x.s || x.b - y.b);
  const top1 = Object.keys(places).find(n => places[n] == 1);
  // top 1 stuck on a losing team: they lose nothing, winners get less
  const special = !T.slice(0, 2).some(x => x.t.includes(top1));
  const win = special ? [40, 15] : [55, 20];
  const deltas = {};
  T.forEach((x, i) => x.t.forEach(n => {
    deltas[n] = i < 2 ? win[i] : (n === top1 ? 0 : -40);
    if (places[n] == 8) deltas[n] -= 5; // last place penalty
  }));
  // carry rule: the 8th place player sits on a winning team, so the teammate takes part of their money
  const p8 = Object.keys(places).find(n => places[n] == 8);
  const ti = T.findIndex(x => x.t.includes(p8));
  if (ti < 2) {
    const carry = T[ti].t.find(n => n !== p8);
    deltas[carry] = ti === 0 ? 80 : 30;
    deltas[p8] = ti === 0 ? 25 : 5;
  }
  // whatever is left over goes into the jar
  const jar = -Object.values(deltas).reduce((a, v) => a + v, 0);
  return { deltas, jar, ranked: T.map(x => ({ team: x.t, score: x.s })) };
}
if (typeof module !== 'undefined') module.exports = { settle };
