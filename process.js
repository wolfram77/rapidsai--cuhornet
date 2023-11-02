const fs = require('fs');
const os = require('os');
const path = require('path');

const RGRAPH = /^Graph File: ([\w-]+)/m;
const RORDER = /^@File\s+V: (.+?)\s+E: (.+?)\s+Structure/m;
const RTREAD = /^Time to read graph file: (.+?)ms/m;
const RTINIT = /^Time to initialize Hornet: (.+?)ms/m;
const RTKATZ = /^Total time for KC\s+: (.+)/m;




// *-FILE
// ------

function readFile(pth) {
  var d = fs.readFileSync(pth, 'utf8');
  return d.replace(/\r?\n/g, '\n');
}

function writeFile(pth, d) {
  d = d.replace(/\r?\n/g, os.EOL);
  fs.writeFileSync(pth, d);
}




// *-CSV
// -----

function writeCsv(pth, rows) {
  var cols = Object.keys(rows[0]);
  var a = cols.join()+'\n';
  for (var r of rows)
    a += [...Object.values(r)].map(v => `"${v}"`).join()+'\n';
  writeFile(pth, a);
}




// *-LOG
// -----

function readLogLine(ln, data, state) {
  if (RGRAPH.test(ln)) {
    var [, graph] = RGRAPH.exec(ln);
    if (!data.has(graph)) data.set(graph, []);
    state = {graph};
  }
  else if (RORDER.test(ln)) {
    var [, order, size] = RORDER.exec(ln);
    state.order = parseFloat(order.replace(/,/g, ''));
    state.size  = parseFloat(size.replace(/,/g, ''));
  }
  else if (RTREAD.test(ln)) {
    var [, read_time] = RTREAD.exec(ln);
    state.read_time = parseFloat(read_time);
  }
  else if (RTINIT.test(ln)) {
    var [, init_time] = RTINIT.exec(ln);
    state.init_time = parseFloat(init_time);
  }
  else if (RTKATZ.test(ln)) {
    var [, katz_centrality_time] = RTKATZ.exec(ln);
    data.get(state.graph).push(Object.assign({}, state, {
      katz_centrality_time: parseFloat(katz_centrality_time),
    }));
  }
  return state;
}

function readLog(pth) {
  var text  = readFile(pth);
  var lines = text.split('\n');
  var data  = new Map();
  var state = null;
  for (var ln of lines)
    state = readLogLine(ln, data, state);
  return data;
}




// PROCESS-*
// ---------

function processCsv(data) {
  var a = [];
  for (var rows of data.values())
    a.push(...rows);
  return a;
}




// MAIN
// ----

function main(cmd, log, out) {
  var data = readLog(log);
  if (path.extname(out)==='') cmd += '-dir';
  switch (cmd) {
    case 'csv':
      var rows = processCsv(data);
      writeCsv(out, rows);
      break;
    case 'csv-dir':
      for (var [graph, rows] of data)
        writeCsv(path.join(out, graph+'.csv'), rows);
      break;
    default:
      console.error(`error: "${cmd}"?`);
      break;
  }
}
main(...process.argv.slice(2));
