import 'package:flutter/material.dart';
import 'package:pocketbook/category_creation.dart';
import 'package:pocketbook/database_handler.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
  }



class _CategoriesScreenState extends State<CategoriesScreen> {
  //categories list
  List<Category> categories = [];
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;
  bool _loading = true;

  Future<void> getCategoryList() async {

    List<Map<String, Object?>> userCategories = await db.getCategories(DatabaseHandler.userID);

      categories = [];
      for (int i = 0; i < userCategories.length; i++) {
        categories.add(createCategoryObject(userCategories[i]));
      }
      setState(() {_loading = false;});
  }
  Category createCategoryObject(Map<String, Object?> category) {
    //for each in categories, make an object with the data
    Category newCategory = Category(name: category['category'] as String, budget: category['amount'] as double, color: Color(int.parse("${category['category_color']}", radix: 16)));
    return newCategory;
  }

  void reloadPage() {
    setState(() {
      _loading = true;
    });
    getCategoryList();
  }

  @override
  void initState() {
    super.initState();
   getCategoryList();
    
  }

  @override
  Widget build(BuildContext context) {

    if (_loading)
    {
      return Scaffold(
       backgroundColor: const Color(0xFF280039), 
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
          backgroundColor: const Color(0xFF280039),
          foregroundColor: Colors.white,
          elevation: 40,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryCreation(),
                    ),
                  ).then((value) => reloadPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9B71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color(0xFF280039),
                      width: 3,
                    ),
                  ),
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.9,
                    MediaQuery.of(context).size.height * 0.05,
                  ),
                ),
                child: const Text(
                  'Create Category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      );
    }
    else
    {
      return Scaffold(
       backgroundColor: const Color(0xFF280039), 
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryCreation(),
                  ),
                ).then((value) => reloadPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9B71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: Color(0xFF280039),
                    width: 3,
                  ),
                ),
                minimumSize: Size(
                  MediaQuery.of(context).size.width * 0.9,
                  MediaQuery.of(context).size.height * 0.05,
                ),
              ),
              child: const Text(
                'Create Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async{
                     await Navigator.of(  context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryCreation(initialCategory: category),
                        ),
                      );
                      reloadPage();
                    },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${category.budget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      );
      }
    }
  }
  