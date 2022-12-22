# node-srec
Motorola SREC library for nodejs


# API:

```var data = readSrecFile(filename)```
reads a srec file and calls back with dictionary:
```
{
 recs: {
    '134217728': [
        0, 64,   0, 32, 249, 90,
        0,  8, 113, 91,   0,  8,
      113, 91,   0,  8
    ],
  },
  min: 134217728,
  max: 134248328,
  boot: 134217728,
  info: 'a.srec'
 };
 ```
 min and max are the address range of the source, info is the decoded string from 0-record.

```blks = blockify(data, data.min, data.max, blen)```
Builds blocks of blen size from a data read with readSrecFile.
Flashing devices is usually done with fixed sized blocks padded with 0xff:
```
  '2047': [
    255, 255, 255, 255, 255, 255,  65,   9,   4,   3,   0,   9,
      0,   0,   0,  32,   0,  32,   0,   2,  20, 112, 103, 109,
     50,  51, 201,  20,  85, 211, 140, 140,  17, 204, 140,  76,
    177,  70,  86, 214, 246,  70, 200, 149, 217,   5,  33,  56,
     50,  51,  55,  52,  56,  50,  51,   7, 150, 204,  12, 141,
    205,  13,  13,  53
  ]
 ```