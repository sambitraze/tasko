// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tasko/models/task.dart';
import 'package:tasko/services/auth_service.dart';
import 'package:tasko/services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<bool> isSelected = List.generate(10, (index) => false);
  List<Task> undoneTasks = [];
  List<Task> doneTasks = [];
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();
  List<TextEditingController> subTasks = [];
  bool showLogs = false;
  bool isLoading = true;
  // formkey
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    getInitData();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    for (var element in subTasks) {
      element.dispose();
    }
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

  getInitData() async {
    setState(() {
      isLoading = true;
    });
    undoneTasks = await TaskService.getMyUnDoneTasks();
    doneTasks = await TaskService.getMyDoneTasks();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            subTasks.clear();
            taskNameController.clear();
            taskDescriptionController.clear();
          });
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: formKey,
                        child: Wrap(
                          children: <Widget>[
                            const Text(
                              'Add a new Task',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Checkbox(
                                    value: false,
                                    onChanged: (val) {},
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: TextFormField(
                                    controller: taskNameController,
                                    validator: (value) => value == ""
                                        ? "Please Enter Task Headline"
                                        : null,
                                    decoration: const InputDecoration(
                                      // labelText: 'Write Task Name here...',
                                      hintText: "Write Task Name here...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: TextFormField(
                                      controller: taskDescriptionController,
                                      validator: (value) => value == null
                                          ? "Please Enter Task Description"
                                          : null,
                                      minLines: 1,
                                      maxLines: 5,
                                      decoration: const InputDecoration(
                                        // labelText: 'Write notes here...',
                                        hintText: "Write notes here...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 64),
                              child: ReorderableListView.builder(
                                shrinkWrap: true,
                                itemCount: subTasks.length,
                                onReorder: (int start, int current) {
                                  FocusScope.of(context).unfocus();
                                  // dragging from top to bottom
                                  if (start < current) {
                                    int end = current - 1;
                                    TextEditingController startItem =
                                        subTasks[start];
                                    int i = 0;
                                    int local = start;
                                    do {
                                      subTasks[local] = subTasks[++local];
                                      i++;
                                    } while (i < end - start);
                                    subTasks[end] = startItem;
                                  }
                                  // dragging from bottom to top
                                  else if (start > current) {
                                    TextEditingController startItem =
                                        subTasks[start];
                                    for (int i = start; i > current; i--) {
                                      subTasks[i] = subTasks[i - 1];
                                    }
                                    subTasks[current] = startItem;
                                  }
                                  setState(() {});
                                },
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    shape: Border(
                                      top:
                                          const BorderSide(color: Colors.black),
                                      bottom: index == subTasks.length - 1
                                          ? const BorderSide(
                                              color: Colors.black)
                                          : BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    key: Key(index.toString()),
                                    leading: Checkbox(
                                      value: false,
                                      onChanged: (val) {},
                                    ),
                                    trailing: const Icon(Icons.menu),
                                    title: TextFormField(
                                      controller: subTasks[index],
                                      decoration: const InputDecoration(
                                        // labelText: 'Write sub notes here...',
                                        hintText: "Write sub notes here...",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    TextEditingController myController =
                                        TextEditingController();
                                    setState(() {
                                      subTasks.add(myController);
                                    });
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle_outline),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text("Add Checklist"),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MaterialButton(
                                  height: 50,
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      subTasks.clear();
                                      taskNameController.clear();
                                      taskDescriptionController.clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  height: 50,
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if (formKey.currentState!.validate()) {
                                      var payload = {
                                        "name": taskNameController.text,
                                        "description":
                                            taskDescriptionController.text == ""
                                                ? "No Description"
                                                : taskDescriptionController
                                                    .text,
                                        "checklist": subTasks
                                            .map((e) => {
                                                  "subtask": e.text.isEmpty
                                                      ? "Unknown Task"
                                                      : e.text,
                                                  "status": false
                                                })
                                            .toList(),
                                        "status": false
                                      };
                                      Task? resp =
                                          await TaskService.addMyTasks(payload);
                                      if (resp != null) {
                                        Fluttertoast.showToast(
                                          msg: "Task added successfully",
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Something went wrong",
                                        );
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Please try again",
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Add Task',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          );
          await getInitData();
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset("assets/images/task_icon.png"),
                const SizedBox(width: 16),
                const Text(
                  "Tasks",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Image.asset("assets/images/dropdown_icon.png"),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await getInitData();
                    }),
                const SizedBox(width: 16),
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await AuthService.logOut(context);
                    })
              ],
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: undoneTasks.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Dismissible(
                          dragStartBehavior: DragStartBehavior.start,
                          key: UniqueKey(),
                          background: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xff488AD8),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(16, 0.0, 0.0, 0.0),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4, 0.0, 0.0, 0.0),
                                  child: Text(
                                    "Check".toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xffD84848),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(0.0, 0.0, 4, 0.0),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 16, 0.0),
                                  child: Text(
                                    "Delete".toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              final bool res = await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Delete Task!"),
                                    content: Text(
                                        "Are you sure you want to delete ${undoneTasks[index].name} ?"),
                                    actions: <Widget>[
                                      MaterialButton(
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      MaterialButton(
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          await TaskService.deleteMyTasks(
                                            undoneTasks[index].id,
                                          );
                                          setState(() {
                                            undoneTasks.removeAt(index);
                                          });
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              return res;
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              final bool res = await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Complete Task!"),
                                    content: Text(
                                        "Are you sure you want to mark ${undoneTasks[index].name} as completed ?"),
                                    actions: <Widget>[
                                      MaterialButton(
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      MaterialButton(
                                        child: const Text(
                                          "Mark as completed",
                                          style: TextStyle(
                                              color: Color(0xff488AD8)),
                                        ),
                                        onPressed: () async {
                                          await TaskService.updateMyTasks(
                                              undoneTasks[index].id, {
                                            "status": true,
                                            "checklist": undoneTasks[index]
                                                        .checklist !=
                                                    null
                                                ? undoneTasks[index]
                                                    .checklist!
                                                    .map((e) => {
                                                          "subtask": e.subtask,
                                                          "status": true
                                                        })
                                                    .toList()
                                                : [],
                                          });
                                          setState(() {
                                            undoneTasks[index].status = true;
                                            doneTasks.add(undoneTasks[index]);
                                            doneTasks =
                                                doneTasks.reversed.toList();
                                            undoneTasks.removeAt(index);
                                          });
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              return res;
                            }
                            return null;
                          },
                          child: GestureDetector(
                            onTap: () async {
                              await showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                isDismissible: false,
                                builder: (BuildContext context) {
                                    bool status = undoneTasks[index].status!;
                                    List<Checklist> tempChecklist =
                                        undoneTasks[index].checklist ?? [];
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Form(
                                          key: formKey,
                                          child: Wrap(
                                            children: <Widget>[
                                              const Text(
                                                'Task Details',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Checkbox(
                                                      value: status,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          status = !status;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 9,
                                                    child: Text(
                                                      undoneTasks[index]
                                                          .name!,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 60, bottom: 16),
                                                child: Text(
                                                  undoneTasks[index]
                                                          .description ??
                                                      "No Description",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .grey.shade500),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 64),
                                                child: ReorderableListView
                                                    .builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      tempChecklist.length,
                                                  onReorder: (int start,
                                                      int current) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    // dragging from top to bottom
                                                    if (start < current) {
                                                      int end = current - 1;
                                                      Checklist startItem =
                                                          tempChecklist[
                                                              start];
                                                      int i = 0;
                                                      int local = start;
                                                      do {
                                                        subTasks[local] =
                                                            subTasks[++local];
                                                        i++;
                                                      } while (
                                                          i < end - start);
                                                      tempChecklist[end] =
                                                          startItem;
                                                    }
                                                    // dragging from bottom to top
                                                    else if (start >
                                                        current) {
                                                      Checklist startItem =
                                                          tempChecklist[
                                                              start];
                                                      for (int i = start;
                                                          i > current;
                                                          i--) {
                                                        subTasks[i] =
                                                            subTasks[i - 1];
                                                      }
                                                      tempChecklist[current] =
                                                          startItem;
                                                    }
                                                    setState(() {});
                                                  },
                                                  itemBuilder:
                                                      (context, ind) {
                                                    return ListTile(
                                                      shape: Border(
                                                        top: const BorderSide(
                                                            color:
                                                                Colors.black),
                                                        bottom: ind ==
                                                                tempChecklist
                                                                        .length -
                                                                    1
                                                            ? const BorderSide(
                                                                color: Colors
                                                                    .black)
                                                            : BorderSide.none,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      key: Key(
                                                          index.toString()),
                                                      leading: Checkbox(
                                                        value:
                                                            tempChecklist[ind]
                                                                .status,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            tempChecklist[ind]
                                                                    .status =
                                                                !tempChecklist[
                                                                        ind]
                                                                    .status!;
                                                          });
                                                        },
                                                      ),
                                                      trailing: const Icon(
                                                          Icons.menu),
                                                      title: Text(
                                                          tempChecklist[ind]
                                                              .subtask!),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () {
                                                      if (!status) {
                                                        for (int i = 0;
                                                            i <
                                                                tempChecklist
                                                                    .length;
                                                            i++) {
                                                          setState(() {
                                                            tempChecklist[i]
                                                                    .status =
                                                                true;
                                                          });
                                                        }
                                                      } else {
                                                        for (int i = 0;
                                                            i <
                                                                tempChecklist
                                                                    .length;
                                                            i++) {
                                                          setState(() {
                                                            tempChecklist[i]
                                                                    .status =
                                                                undoneTasks[
                                                                        index]
                                                                    .checklist![
                                                                        i]
                                                                    .status;
                                                          });
                                                        }
                                                      }
                                                      setState(() {
                                                        status = !status;
                                                      });
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        status
                                                            ? const Icon(
                                                                Icons.restore)
                                                            : const Icon(Icons
                                                                .add_circle_outline),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        status
                                                            ? const Text(
                                                                "Reset")
                                                            : const Text(
                                                                "Complete All"),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MaterialButton(
                                                    height: 50,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  MaterialButton(
                                                    height: 50,
                                                    color: Colors.green,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                    onPressed: () async {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      var payload = {
                                                        "checklist":
                                                            tempChecklist
                                                                .map(
                                                                    (e) => {
                                                                          "subtask":
                                                                              e.subtask ?? "Unknown Task",
                                                                          "status":
                                                                              e.status
                                                                        })
                                                                .toList(),
                                                        "status": status
                                                      };
                                                      bool resp =
                                                          await TaskService
                                                              .updateMyTasks(
                                                                  undoneTasks[
                                                                          index]
                                                                      .id,
                                                                  payload);
                                                      if (resp) {
                                                        Fluttertoast
                                                            .showToast(
                                                          msg:
                                                              "Task updated successfully",
                                                        );
                                                        Navigator.pop(
                                                            context);
                                                        await getInitData();
                                                      } else {
                                                        Fluttertoast
                                                            .showToast(
                                                          msg:
                                                              "Something went wrong",
                                                        );
                                                        Navigator.pop(
                                                            context);
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Update Task',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    value: undoneTasks[index].status,
                                    onChanged: (value) {
                                      setState(() {
                                        undoneTasks[index].status = true;
                                        doneTasks.add(undoneTasks[index]);
                                        doneTasks = doneTasks.reversed.toList();
                                        undoneTasks.removeAt(index);
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    undoneTasks[index].name ?? "",
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  undoneTasks[index].checklist!.isEmpty
                                      ? const SizedBox()
                                      : const Icon(Icons.account_tree),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            isLoading ? const SizedBox() : const SizedBox(height: 4),
            isLoading
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showLogs = !showLogs;
                      });
                    },
                    child: SizedBox(
                      height: 40,
                      child: showLogs
                          ? Row(
                              children: [
                                Text("Hide ${doneTasks.length} logged items"),
                                const Icon(Icons.keyboard_arrow_up)
                              ],
                            )
                          : Row(
                              children: [
                                Text("Show ${doneTasks.length} logged items"),
                                const Icon(Icons.keyboard_arrow_down)
                              ],
                            ),
                    ),
                  ),
            isLoading ? const SizedBox() : const SizedBox(height: 4),
            isLoading
                ? const SizedBox()
                : showLogs
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: doneTasks.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                await showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Form(
                                              key: formKey,
                                              child: Wrap(
                                                children: <Widget>[
                                                  const Text(
                                                    'Task Details',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Checkbox(
                                                          value: true,
                                                          onChanged: (val) {},
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 9,
                                                        child: Text(
                                                          doneTasks[index]
                                                              .name!,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 60,
                                                            bottom: 16),
                                                    child: Text(
                                                      doneTasks[index]
                                                              .description ??
                                                          "No Description",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade500),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 64),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          doneTasks[index]
                                                              .checklist!
                                                              .length,
                                                      itemBuilder:
                                                          (context, ind) {
                                                        return ListTile(
                                                          shape: Border(
                                                            top: const BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            bottom: ind ==
                                                                    doneTasks[index]
                                                                            .checklist!
                                                                            .length -
                                                                        1
                                                                ? const BorderSide(
                                                                    color: Colors
                                                                        .black)
                                                                : BorderSide
                                                                    .none,
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          key: Key(
                                                              index.toString()),
                                                          leading: Checkbox(
                                                            value: true,
                                                            onChanged: (val) {},
                                                          ),
                                                          title: Text(doneTasks[
                                                                  index]
                                                              .checklist![ind]
                                                              .subtask!),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        MaterialButton(
                                                          height: 50,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              subTasks.clear();
                                                              taskNameController
                                                                  .clear();
                                                              taskDescriptionController
                                                                  .clear();
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                            'Close',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      value: true,
                                      onChanged: (value) {
                                        // setState(() {
                                        //   isSelected[index] = value!;
                                        // });
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      "${doneTasks[index].name}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    doneTasks[index].checklist!.isEmpty
                                        ? const SizedBox()
                                        : const Icon(Icons.account_tree),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
            isLoading ? const SizedBox() : const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
