import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
    final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

    // NOTE: CREATE 
    Future<void> create({required String path, required Map<String, dynamic> data,}) async {
        final DatabaseReference ref = _firebaseDatabase.ref().child(path);
        await ref.set(data);
    }

    // NOTE: READ
    Future<DataSnapshot?> read({required String path}) async {
        final DatabaseReference ref = _firebaseDatabase.ref().child(path);
        final DataSnapshot snapshot = await ref.get();
        return snapshot.exists ? snapshot : null;
    }

    // NOTE: LISTEN
    Stream<DatabaseEvent> stream(String path) {
        return _firebaseDatabase.ref(path).onValue;
    }

    // NOTE: UPDATE
    Future<void> update({required String path, required Map<String, dynamic> data,}) async {
        final DatabaseReference ref = _firebaseDatabase.ref().child(path);
        await ref.update(data);
    }

    // NOTE: DELETE 
    Future<void> delete({required String path}) async {
        final DatabaseReference ref = _firebaseDatabase.ref().child(path);
        await ref.remove();
    }
}
