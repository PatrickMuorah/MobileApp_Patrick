import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_providers/expense_provider.dart';
import '../widgets/add_subcategory_dialog.dart';

class SubcategoryManagementScreen extends StatelessWidget {
  const SubcategoryManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Subcategories"),
        backgroundColor: Colors.deepPurple, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = provider.subcategories[index];
              return ListTile(
                title: Text(subcategory.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Delete the task
                    final deleteSubcategory = provider.deleteSubCategory(subcategory.id);
                    if (!deleteSubcategory) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${subcategory.name} cannot be deleted')));
                    }
                    
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddSubcategoryDialog(
              onAdd: (newSubcategory) {
                Provider.of<ExpenseProvider>(context, listen: false).addSubcategory(newSubcategory);
              }
            ),
          );
        },
        tooltip: 'Add New Subcategory',
        child: Icon(Icons.add),
      ),
    );
  }
}
