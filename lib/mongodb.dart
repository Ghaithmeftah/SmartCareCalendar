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
    String h = ch[0] + ch[1];
    String min = ch[3] + ch[4];
    return {"hour": int.parse(h), "minites": int.parse(min)};
  }

  static connect() async {
    //connect to the db using these two lines
    var db = await Db.create(MONGO_URL);
    await db.open();

    inspect(db);
    //we had opened our collection name the COLLECTION_NAME = (DoctorsCalendar)
    /*var collection = db.collection(COLLECTION_NAME);
    //now we are inserting this document
    await collection.insertOne({
      "id": "1",
      "startTime": "08:00",
      "endTime": "17:00",
      "debut_pause": "12:00",
      "fin_pause": "13:00",
      "duration": "30",
      "weekend": "dimanche"
    });*/

    //you're inserting a lot of data in one go
    /*await collection.insertMany([
      {
        'username': 'mp1',
        'name': 'Ghaith Meftah1',
        'email': 'ghaithmeftah1@gmail.com'
      },
      {
        'username': 'mp2',
        'name': 'Ghaith Meftah2',
        'email': 'ghaithmeftah2@gmail.com'
      },
      {
        'username': 'mp3',
        'name': 'Ghaith Meftah3',
        'email': 'ghaithmeftah3@gmail.com'
      }
    ]);*/
/*
    print(await collection.find().toList());
    //update the first username eq to mp
    await collection.update(
      where.eq('username', 'mp'),
      modify.set('name', 'Max P1'),
    );
    //update all the usernames eq to mp
    await collection.updateMany(
      where.eq('username', 'mp'),
      modify.set('name', 'Max P'),
    );
    print(await collection.find().toList());

    //delete one element
    //await collection.deleteOne({"username": "mp"});

    //delete all elements with username = mp
    //await collection.deleteMany({"username": "mp"});*/
  }
}

/*create a new document :
static insert(User user) async {
    await userCollection.insertAll([user.toMap()]);
  }
Read a all documents :
static Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final users = await userCollection.find().toList();
      return users;
    } catch (e) {
      print(e);
      return Future.value(e);
    }
  }
update document:
static update(User user) async {
    var u = await userCollection.findOne({"_id": user.id});
    u["name"] = user.name;
    u["age"] = user.age;
    u["phone"] = user.phone;
    await userCollection.save(u);
  }
  delete a document :
  static delete(User user) async {
    await userCollection.remove(where.id(user.id));
  }
  */
