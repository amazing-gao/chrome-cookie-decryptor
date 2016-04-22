#!/usr/bin/env node

var aesKey, crypto, decryptor, kDerivedKeySizeInBits, kEncryptionIterations, kEncryptionVersionPrefix, kFilterHost, kIv, kPass, kPath, kSalt, sqlite3, start;

crypto = require('crypto');
sqlite3 = require('sqlite3').verbose();

kPath = null;
kPass = null;
kFilterHost = null;
kFilterName = null;

kSalt = 'saltysalt';
kIv = new Buffer('                ');
kDerivedKeySizeInBits = 128;
kEncryptionIterations = 1003;
kEncryptionVersionPrefix = "v10";

aesKey = function(password, salt, done) {
  return crypto.pbkdf2(password, salt, kEncryptionIterations, kDerivedKeySizeInBits / 8, 'sha1', done);
};

decryptor = function(key, iv, data) {
  var decipher, decrypted, e, error1;
  try {
    decipher = crypto.createDecipheriv('AES-128-CBC', key, iv);
    decrypted = decipher.update(data, 'binary', 'binary');
    return decrypted + decipher.final('binary');
  } catch (error1) {
    e = error1;
    return console.log('error: ', e.message);
  }
};

start = function(path, pass) {
  return aesKey(pass, kSalt, function(error, key) {
    var db;
    db = new sqlite3.Database(path, function(error) {
      if (error) {
        return console.log(error);
      }
    });
    return db.each("SELECT * from cookies", function(err, row) {
      var ret;
      if (kFilterHost && row.host_key !== kFilterHost) {
        return;
      }
      if (kFilterName && row.name !== kFilterName) {
        return;
      }

      if (row.encrypted_value.indexOf(kEncryptionVersionPrefix) === 0) {
        row.encrypted_value = row.encrypted_value.slice(3);
      }
      ret = decryptor(key, kIv, row.encrypted_value);

      row.encrypted_value = ret;
      if (kFilterName)
        console.log(row.encrypted_value);
      else
        console.log(row);
    });
  });
};


if (process.argv.length <= 2) {
  console.log("使用方法: \n\t decryptor cookie文件路径 chrome钥匙串 [cookie的host] [cookie的名字]\n")
  console.log("Mac下获取chrome钥匙串: \n\t security find-generic-password -w -s \"Chrome Safe Storage\"")
} else {
  kPath = process.argv[2]
  kPass = process.argv[3]
  kFilterHost = process.argv[4]
  kFilterName = process.argv[5]

  start(kPath, kPass)
}
