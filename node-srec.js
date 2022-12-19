fs = require('fs');
request = require('request');
sprintf = require('sprintf').sprintf;

module.exports.block2srec = block2srec = (a, data) => {
  var byte, j, len1, s, sum;
  sum = data.length + 5;
  sum += a & 0xff;
  sum += (a >> 8) & 0xff;
  sum += (a >> 16) & 0xff;
  sum += (a >> 24) & 0xff;
  s = sprintf("S3%02X%08X", data.length + 5, a);
  for (j = 0, len1 = data.length; j < len1; j++) {
    byte = data[j];
    s += sprintf("%02X", byte);
    sum += byte;
  }
  sum = (~sum) & 0xff;
  s += sprintf("%02X", sum);
  return s;
};

module.exports.parseSrec = parseSrec = (data) => {
  var addr, alen, b, boot, byte, dp, i, info, j, k, l, len, len1, len2, max, mem, min, ref, ref1, s, srecs, type;
  mem = {};
  info = "";
  min = max = boot = null;
  srecs = data.split("\n");
  for (j = 0, len1 = srecs.length; j < len1; j++) {
    s = srecs[j];
    if (s[0] === "S") {
      switch (type = parseInt(s[1])) {
        case 0:
        case 1:
        case 9:
        case 5:
          alen = 2;
          break;
        case 2:
        case 6:
        case 8:
          alen = 3;
          break;
        case 3:
        case 7:
          alen = 4;
          break;
        default:
          continue;
      }
      addr = parseInt(s.slice(4, 4 + alen * 2), 16);
      dp = 4 + alen * 2;
      b = [];
      len = parseInt(s.slice(2, 4), 16);
      for (i = k = ref = alen + 2, ref1 = len; ref <= ref1 ? k <= ref1 : k >= ref1; i = ref <= ref1 ? ++k : --k) {
        b.push(parseInt(s.slice(i * 2, +(i * 2 + 1) + 1 || 9e9), 16));
      }
      switch (type) {
        case 1:
        case 2:
        case 3:
          mem[addr] = b;
          if (!min || addr < min) {
            min = addr;
          }
          if (!max || addr + b.length > max) {
            max = addr;
          }
          break;
        case 7:
        case 8:
        case 9:
          boot = addr;
          break;
        case 0:
          for (l = 0, len2 = b.length; l < len2; l++) {
            byte = b[l];
            info += String.fromCharCode(byte);
          }
      }
    }
  }
  return {
    recs: mem,
    min: min,
    max: max,
    boot: boot,
    info: info
  };
};

cache = {};

module.exports.readSrecFile = (fn, cb) => {
  console.log("node-srec: Reading File: '" + fn + "'");
  return fs.readFile(fn, 'utf8', function(error, data) {
    cache[fn] = parseSrec(data);
    return cb(cache[fn]);
  });
};

module.exports.readSrecUrl = (url, cb) => {
  console.log("node-srec: Getting Url: '" + url + "'");
  return request.get(url, function(error, response, body) {
    if (!error && response && response.statusCode === 200) {
      cache[url] = parseSrec(body);
      return cb(cache[url]);
    } else {
      console.log("Error: cannot get " + url + "?? " + response);
      return cb("", "Error: cannot get " + url + " error: " + error + " http-status:" + response);
    }
  });
};

module.exports.blockify = (data, min, max, size) => {
  var a, as, b, blk, blks, donee, i, j, len, oset, ref, ref1;
  blks = {};
  console.log("node-srec: Blockify", min.toString(16), max.toString(16), size);
  donee = false;
  for (as in data.recs) {
    b = data.recs[as];
    a = parseInt(as);
    len = b.length;
    for (var i = 0; i<len ; i++) {
      if (a + i > max || a + i < min) {
        if (!donee) {
          console.log("Error -- out of range: " + ((a + i).toString(16)) + " [" + (min.toString(16)) + ".." + (max.toString(16)) + "]");
          donee = true;
        }
        continue;
      }
      blk = Math.floor((a + i - min) / size);
      oset = (a + i - min) % size;
      if (!blks[blk]) {
        blks[blk] = Array.apply(null, new Array(size)).map(Number.prototype.valueOf, 0xff);
      }
      if (b[i] === void 0) {
        console.log("????? ", i, len);
      }
      blks[blk][oset] = b[i];
    }
  }
  return blks;
};

