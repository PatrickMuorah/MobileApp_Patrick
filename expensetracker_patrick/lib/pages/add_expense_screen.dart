import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../data_providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_subcategory_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? initialExpense;

  const AddExpenseScreen({super.key, this.initialExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  //late TextEditingController _payeeController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  DateTime _selectedDate = DateTime.now();
  late TextEditingController _payeeController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.initialExpense?.amount.toString() ?? '');
    // _payeeController =
    //     TextEditingController(text: widget.initialExpense?.payee ?? '');
    _noteController =
        TextEditingController(text: widget.initialExpense?.notes ?? '');
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();
    _selectedCategoryId = widget.initialExpense?.categoryId;
    _selectedSubcategoryId = widget.initialExpense?.subcategoryId;
       _payeeController = TextEditingController(text: widget.initialExpense?.payeeName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialExpense == null ? 'Add Expense' : 'Edit Expense'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Adjust the padding as needed
              child: buildProjectDropdown(expenseProvider),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Adjust the padding as needed
              child: buildTaskDropdown(expenseProvider),
            ),
            buildDateField(_selectedDate),
            buildTextField(_amountController, 'Amount (dollars)',
                TextInputType.numberWithOptions(decimal: true)),
            buildTextField(_noteController, 'note', TextInputType.text),
            buildTextField(_payeeController, 'Payee Name', TextInputType.text),
            // buildCategoryDropdown(expenseProvider),
            // buildTagDropdown(expenseProvider),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: _saveExpense,
          child: Text('Save Expense'),
        ),
      ),
    );
  }
  // Helper methods for building the form elements go here (omitted for brevity)

  void _saveExpense() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields!')));
      return;
    }
    if(_selectedCategoryId == null || _selectedSubcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a category and a subcategory!')));
      return;
    }
    

    final expense = Expense(
      id: widget.initialExpense?.id ?? Provider.of<ExpenseProvider>(context, listen: false).generateExpenseId().toString(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      subcategoryId: _selectedSubcategoryId!,
      notes: _noteController.text,
      date: _selectedDate,
      payeeName: _payeeController.text,
    );

    // Calling the provider to add or update the expense
    Provider.of<ExpenseProvider>(context, listen: false)
        .addOrUpdateExpenses(expense);
    Navigator.pop(context);
  }

  // Helper method to build a text field
  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: type,
      ),
    );
  }

// Helper method to build the date picker field
  Widget buildDateField(DateTime selectedDate) {
    return ListTile(
      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

// Helper method to build the project dropdown
  Widget buildProjectDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(onAdd: (newCategory) {
              setState(() {
                _selectedCategoryId =
                    newCategory.id; // Automatically select the new category
                provider.addCategory(
                    newCategory); // Add to provider, assuming this method exists
              });
            }),
          );
        } else {
          setState(() => _selectedCategoryId = newValue);
        }
      },
      items: provider.categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("Add New Category"),
        )),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
    );
  }

// Helper method to build the subcategory dropdown
  Widget buildTaskDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSubcategoryId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddSubcategoryDialog(onAdd: (newSubcategory) {
              provider.addSubcategory(newSubcategory); // Assuming you have an `addTask` method.
              setState(
                  () => _selectedSubcategoryId = newSubcategory.id); // Update selected tag ID
            }),
          );
        } else {
          setState(() => _selectedSubcategoryId = newValue);
        }
      },
      items: provider.subcategories.map<DropdownMenuItem<String>>((subcategories) {
        return DropdownMenuItem<String>(
          value: subcategories.id,
          child: Text(subcategories.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("Add New Subcategory"),
        )),
      decoration: InputDecoration(
        labelText: 'Subcategory',
        border: OutlineInputBorder(),
      ),
    );
  }
}
