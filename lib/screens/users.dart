import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final Dio _dio = Dio();
  final _formKey = GlobalKey<FormState>();
  List<dynamic> users = [];
  bool isLoading = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final url = 'http://192.168.79.143:4000/';
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _dio.post(
          url + 'users',
          data: {
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ User added: ${response.data}')),
        );
        fetchUsers();
      } catch (e) {
        if (e is DioException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${e.response?.data}')),
          );
        } else {
          print("❌ Unexpected error: $e");
        }
      }
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await _dio.get(url + 'users');
      setState(() {
        users = response.data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to load users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchUser(String email) async {
    try {
      final response = await _dio.get(url + 'users/search/$email');
      setState(() {
        users = response.data;
        isLoading = false;
      });
      // fetchUsers();
    } catch (e) {
      print("❌ Failed to delete user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ເພີ່ມຜູ້ໃຊ້")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(labelText: 'search'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter username' : null,
              ),
              ElevatedButton(onPressed: (){searchUser(_searchController.text);}, child: Text('Search')),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter username' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) => value!.isEmpty ? 'Please enter password' : null,
              ),
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: registerUser,
                      child: Text('Add User'),
                    ),
                    SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: fetchUsers,
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['username']![0].toUpperCase()),
                        ),
                        title: Text(user['username'] ?? ''),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () async {
                                  final userData = await _dio.get(
                                    url + 'users/${user['id']}',
                                  );

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled:
                                        true, // ให้ modal เต็มหน้าจอ
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) {
                                      final TextEditingController
                                      nameController = TextEditingController(
                                        text: userData.data['username'],
                                      );
                                      final TextEditingController
                                      emailController = TextEditingController(
                                        text: userData.data['email'],
                                      );

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom,
                                          left: 20,
                                          right: 20,
                                          top: 20,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'แก้ไขผู้ใช้',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                labelText: 'ชื่อ',
                                              ),
                                            ),
                                            TextField(
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                labelText: 'อีเมล',
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await _dio.patch(
                                                    url + 'users/${user['id']}',
                                                    data: {
                                                      'username':
                                                          nameController.text,
                                                      'email':
                                                          emailController.text,
                                                    },
                                                  );
                                                  Navigator.pop(context);
                                                  // print(nameController.text);
                                                  fetchUsers(); // โหลดข้อมูลใหม่
                                                } catch (e) {
                                                  print(
                                                    "❌ Failed to update user: $e",
                                                  );
                                                }
                                              },
                                              child: Text('บันทึก'),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('ຍືນຍັນການລົບ'),
                                          content: Text(
                                            'ເຈົ້າຕ້ອງການທີ່ຈະລຶບລາຍການນີ້ບໍ່?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: Text('ຍົກເລີກ'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: Text('ລົບ'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _dio.delete(
                                        url + 'users/${user['id']}',
                                      );
                                      // fetchUsers()
                                      fetchUsers();
                                    } catch (e) {
                                      print("❌ Failed to delete user: $e");
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
