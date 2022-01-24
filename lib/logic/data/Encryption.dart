


import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import "package:pointycastle/export.dart";
import "package:asn1lib/asn1lib.dart";



List<int> decodePEM(String pem) {
  var startsWith = [
    "-----BEGIN PUBLIC KEY-----",
    "-----BEGIN PRIVATE KEY-----",
    "-----BEGIN PGP PUBLIC KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
    "-----BEGIN PGP PRIVATE KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
  ];
  var endsWith = [
    "-----END PUBLIC KEY-----",
    "-----END PRIVATE KEY-----",
    "-----END PGP PUBLIC KEY BLOCK-----",
    "-----END PGP PRIVATE KEY BLOCK-----",
  ];
  bool isOpenPgp = pem.indexOf('BEGIN PGP') != -1;

  for (var s in startsWith) {
    if (pem.startsWith(s)) {
      pem = pem.substring(s.length);
    }
  }

  for (var s in endsWith) {
    if (pem.endsWith(s)) {
      pem = pem.substring(0, pem.length - s.length);
    }
  }

  if (isOpenPgp) {
    var index = pem.indexOf('\r\n');
    pem = pem.substring(0, index);
  }

  pem = pem.replaceAll('\n', '');
  pem = pem.replaceAll('\r', '');

  return base64.decode(pem);
}

class Encryption {
  AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
      var keyParams = new RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);

      var secureRandom = new FortunaRandom();
      var random = new Random.secure();
      List<int> seeds = [];
      for (int i = 0; i < 32; i++) {
          seeds.add(random.nextInt(255));
      }
      secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));

      var rngParams = new ParametersWithRandom(keyParams, secureRandom);
      var k = new RSAKeyGenerator();
      k.init(rngParams);

      var keypair = k.generateKeyPair();
      print(keypair);

      return keypair;
//    var rnd = new FixedSecureRandom();
//    var rsapars = new RSAKeyGeneratorParameters(BigInt.parse("10000"), 1024, 12);
//    var params = new ParametersWithRandom(rsapars, rnd);

//    var keyGenerator = new KeyGenerator("RSA");
//    keyGenerator.init(params);
//    return keyGenerator.generateKeyPair();
//      final n = "24649663692047164444790643172109370056158709234977203368650147515375245495213442567159484352023028564722607846088040100966055452012530635310929880142309672672370384513414361688667706499439717428347689592753696423610988570895714214920908622106527744596538403468957028226105712420419053355165486523922578029360613666994642331140679324765028868432884033287641095549662040120859273059357594690379309402039994712237709233598606723986537440109010028591440539106473660495784943265016397899779881916920074735104005566018575893835392960697074083820748729243932835684709199184189144330411532000389215869317902155568589589990937";
//      final e = "65537";
//      final d = "4063958011391574405693927086602098714570316817735457564402777727140844524097551717932743769528797833923246071333464657993778005691371187490037648274068938358865404346665886110838985133992189859366415704864484029740707257099473459148578934981171434157279055334880764911165787611618289996529640995025458223709324848295784182981653521435775135990468151575617415377402359600649196585978093468870169020045627061059125356549455475504958158218546129405411183104108490830376537830617352916950230417099192711318868054030047466626509446719907850666657436082569747996909170379147599626458818599142452671385912424304169295269813";
//      final p = "172622988945032241272460594823465727338165469761128582817141296878210996104803340949368540074325243384642718754688224642044903791277270607713426667425998282894170126560269953218957312807290242694167112152302773291330789947866948729188625784460892934126377883318018638038433339229978409110366812585246469634979";
//      final q = "142794791369857893518216846152178512365742893193381905408671045383524196038880042688222484665321416966726996826180091369625084659347039997384427839884481875048370565094771341455209579084576003589416828973425288956690619644847967193297411322186095969144940769802524422661706293551748267739368517289465924234003";
//      final publicKey = new RSAPublicKey(BigInt.parse(n), BigInt.parse(e));
//      final privKey = new RSAPrivateKey(BigInt.parse(n), BigInt.parse(d), BigInt.parse(p), BigInt.parse(q));
//      return new AsymmetricKeyPair(
//          publicKey,
//          privKey,);

  }

  String encrypt(String plaintext, PublicKey publicKey) {
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(plaintext).base64;
  }

  String decrypt(String cipherBase64, PrivateKey privateKey) {
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    return encrypter.decrypt64(cipherBase64);
  }

  parsePublicKeyFromPem(pemString) {
    List<int> publicKeyDER = decodePEM(pemString);
    var asn1Parser = new ASN1Parser(publicKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var publicKeyBitString = topLevelSeq.elements[1];

    var publicKeyAsn = new ASN1Parser(publicKeyBitString.contentBytes());
    ASN1Sequence publicKeySeq = publicKeyAsn.nextObject();
    var modulus = publicKeySeq.elements[0] as ASN1Integer;
    var exponent = publicKeySeq.elements[1] as ASN1Integer;

    RSAPublicKey rsaPublicKey = RSAPublicKey(
        modulus.valueAsBigInteger,
        exponent.valueAsBigInteger
    );

    return rsaPublicKey;
  }

  parsePrivateKeyFromPem(pemString) {
    List<int> privateKeyDER = decodePEM(pemString);
    var asn1Parser = new ASN1Parser(privateKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var version = topLevelSeq.elements[0];
    var algorithm = topLevelSeq.elements[1];
    var privateKey = topLevelSeq.elements[2];

    asn1Parser = new ASN1Parser(privateKey.contentBytes());
    var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    version = pkSeq.elements[0];
    var modulus = pkSeq.elements[1] as ASN1Integer;
    var publicExponent = pkSeq.elements[2] as ASN1Integer;
    var privateExponent = pkSeq.elements[3] as ASN1Integer;
    var p = pkSeq.elements[4] as ASN1Integer;
    var q = pkSeq.elements[5] as ASN1Integer;
    var exp1 = pkSeq.elements[6] as ASN1Integer;
    var exp2 = pkSeq.elements[7] as ASN1Integer;
    var co = pkSeq.elements[8] as ASN1Integer;

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
        modulus.valueAsBigInteger,
        privateExponent.valueAsBigInteger,
        p.valueAsBigInteger,
        q.valueAsBigInteger
    );

    return rsaPrivateKey;
  }

  encodePublicKeyToPem(RSAPublicKey publicKey) {
    var algorithmSeq = new ASN1Sequence();
    var algorithmAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
    var paramsAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    var publicKeySeq = new ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus));
    publicKeySeq.add(ASN1Integer(publicKey.exponent));
    var publicKeySeqBitString = new ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

    var topLevelSeq = new ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);
    var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

    return """-----BEGIN PUBLIC KEY-----\r\n$dataBase64\r\n-----END PUBLIC KEY-----""";
  }

  encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    var version = ASN1Integer(BigInt.from(0));

    var algorithmSeq = new ASN1Sequence();
    var algorithmAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
    var paramsAsn1Obj = new ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    var privateKeySeq = new ASN1Sequence();
    var modulus = ASN1Integer(privateKey.n);
    var publicExponent = ASN1Integer(BigInt.parse('65537'));
    var privateExponent = ASN1Integer(privateKey.d);
    var p = ASN1Integer(privateKey.p);
    var q = ASN1Integer(privateKey.q);
    var dP = privateKey.d % (privateKey.p - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.d % (privateKey.q - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q.modInverse(privateKey.p);
    var co = ASN1Integer(iQ);

    privateKeySeq.add(version);
    privateKeySeq.add(modulus);
    privateKeySeq.add(publicExponent);
    privateKeySeq.add(privateExponent);
    privateKeySeq.add(p);
    privateKeySeq.add(q);
    privateKeySeq.add(exp1);
    privateKeySeq.add(exp2);
    privateKeySeq.add(co);
    var publicKeySeqOctetString = new ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));

    var topLevelSeq = new ASN1Sequence();
    topLevelSeq.add(version);
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqOctetString);
    var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

    return """-----BEGIN PRIVATE KEY-----\r\n$dataBase64\r\n-----END PRIVATE KEY-----""";
  }
}