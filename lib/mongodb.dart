import 'dart:developer';

import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static UpdateCalendar(String startTime, String endTime, String debut_pause,
      String fin_pause, String duration, String weekend) async {
    //connect to the db using these two lines
    var db = await Db.create(MONGO_URL);
    await db.open();

    inspect(db);
    var status = db.serverStatus();
    print(status);
    //we had opened our collection name the COLLECTION_NAME = (DoctorsCalendar)
    var collection1 = db.collection(COLLECTION_NAME);
    await collection1.deleteMany(where.eq('id', '1'));
    await collection1.insertOne({
      'id': '1',
      'startTime': startTime,
      'endTime': endTime,
      'debut_pause': debut_pause,
      'fin_pause': fin_pause,
      'duration': duration,
      'weekend': weekend,
    });
    print(await collection1.find().toList());
  }

  static Future<List<Map<String, dynamic>>> getDocument() async {
    //connect to the db using these two lines
    var db = await Db.create(MONGO_URL);
    await db.open();

    inspect(db);
    //we had opened our collection name the COLLECTION_NAME = (DoctorsCalendar)
    var collection = db.collection(COLLECTION_NAME);
    final users = await collection.find().toList();
    return users;
  }

  static Map<String, int> getHourAndMinutesFromMongo(String ch) {
    if (ch.length == 5) {
      String h = ch[0] + ch[1];
      String min = ch[3] + ch[4];
      return {"hour": int.parse(h), "minites": int.parse(min)};
    } else if (ch.length == 4) {
      String h = ch[0];
      String min = ch[2] + ch[3];
      return {"hour": int.parse(h), "minites": int.parse(min)};
    } else {
      return {};
    }
  }

  static connect() async {
    //connect to the db using these two lines
    var db = await Db.create(MONGO_URL);
    await db.open();

    inspect(db);
  }
}
