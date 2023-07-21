// import 'package:objectbox/objectbox.dart';

// @Entity()
// class Message {
//   @Id()
//   int id = 0;
//   String? uuid;
//   String? room;
//   String? text;
//   String? sender;
//   String? messageType;
//   String? messageStatus;
//   @Property(type: PropertyType.date)
//   DateTime? dateCreated;

//   Message({
//     this.uuid,
//     this.room,
//     this.text,
//     this.sender,
//     this.messageType,
//     this.messageStatus,
//     DateTime? dateCreated,
//   }) : dateCreated = dateCreated ?? DateTime.now();
//   // @Transient() // Ignore this property, not stored in the database.
//   // int? computedProperty;
// }
