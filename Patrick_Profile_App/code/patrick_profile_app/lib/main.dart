import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfileScreen(),
    );  
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' My Profile'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),

      // Hambuerger Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('My Hobbies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HobbiesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Favorite Pics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritePicsScreen()),
                );
              },
            ),
          ],
        ),
      ),
           


      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),

              const CircleAvatar(
                radius: 80.0,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 80.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Patrick Muorah',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'Flutter Beginner & App Creator',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 4.0),
                  Text('Atlanta, GA, USA    '),
                  SizedBox(height: 16.0),

                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 4.0),
                  Text('patrick@mydummymail.com'),
              ],
              ),
    
              const SizedBox(height: 25.0),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HobbiesScreen()),
                  );
                },
                child: const Text('My Hobbies'),
              ),
              const SizedBox(height: 16.0),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritePicsScreen()),
                  );
                },
                child: const Text('My Favorite Pics'),
              ),

            
          ],)
        )
      ),
    );
  }
}

// Hobbies
class HobbiesScreen extends StatelessWidget {
  const HobbiesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final hobbies = [
      'Coding Flutter Apps',
      'Playing Video Games',
      'Reading Sci-Fi Books',
      'Photography',
      'Playing Basketball',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hobbies'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18.0),
        itemCount: hobbies.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(hobbies[index]),
            ),
          );
        },
      ),
    );
  }
}

// Favorite Pics
class FavoritePicsScreen extends StatelessWidget {
  const FavoritePicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Pics'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
        children: List.generate(4, (index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image,
                  size: 50.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Picture ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ]
            )
          );
        })
      )
    );
  }
}
