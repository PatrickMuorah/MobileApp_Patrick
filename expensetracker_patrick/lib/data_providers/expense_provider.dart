import 'package:flutter/foundation.dart' hide Category;
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<Expense> _expenses = [];
  List<Subcategory> _subcategories = [];
  List<Category> _categories = [];

  // List of categories
  /*
  final List<Project> _projects = [
    Project(id: '1', name: 'Something Big', isDefault: false),
    Project(id: '2', name: 'Mind Blowing', isDefault: false),
    Project(id: '3', name: 'Fake', isDefault: false),
    Project(id: '4', name: 'Money Hungry', isDefault: false),
    Project(id: '5', name: 'Bottomless Pit', isDefault: false),
  ];

  // List of tags

  final List<Task> _tasks = [
    Task(id: '1', name: 'Breakfast'),
    Task(id: '2', name: 'Lunch'),
    Task(id: '3', name: 'Dinner'),
    Task(id: '4', name: 'Treat'),
    Task(id: '5', name: 'Vacation'),
    Task(id: '6', name: 'Shopping'),    
    Task(id: '7', name: 'SelfCare'),
    Task(id: '8', name: 'Streaming'),
  ];
  */

  // Getters
  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;

  ExpenseProvider(this.storage) {
    _loadCategoriesFromStorage();
    _loadSubCategoriesFromStorage();
    _loadExpenseFromStorage();
  }

  void _loadExpenseFromStorage() {
  var storedExpenses = storage.getItem('expenses');
  if (storedExpenses != null) {
    final List<dynamic> decoded = jsonDecode(storedExpenses);
    _expenses = decoded
        .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
    _saveExpensesToStorage();
  }

}

void _loadCategoriesFromStorage() {
  var storedCategories = storage.getItem('categories');
  if (storedCategories != null) {
    final List<dynamic> decoded = jsonDecode(storedCategories);
    _categories = decoded
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'categories',
        jsonEncode(_categories.map((p) => p.toJson()).toList()),
      );
  }
}

void _loadSubCategoriesFromStorage() {
  var storedSubcategories = storage.getItem('subcategories');
  if (storedSubcategories != null) {
    final List<dynamic> decoded = jsonDecode(storedSubcategories);
    _subcategories = decoded
        .map((item) => Subcategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'subcategories',
        jsonEncode(_subcategories.map((t) => t.toJson()).toList()),
      );
  }
}

  // Add an expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

 void _saveExpensesToStorage() {
  storage.setItem(
    'expenses',
    jsonEncode(_expenses.map((e) => e.toJson()).toList()),
  );
}

  void addOrUpdateExpenses(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      // Update existing expense
      _expenses[index] = expense;
    } else {
      // Add new expense
      _expenses.add(expense);
    }
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an expense
  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a category
  void addCategory(Category category) {
    if (!_categories.any((p) => p.name == category.name)) {
      _categories.add(category);
      storage.setItem(
        'categories',
        jsonEncode(_categories.map((p) => p.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  //add subcategory
  void addSubcategory(Subcategory subcategory) {
    if (!_subcategories.any((t) => t.name == subcategory.name)) {
      _subcategories.add(subcategory);
      storage.setItem(
        'subcategories',
        jsonEncode(_subcategories.map((t) => t.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  // Delete a category
  bool deleteCategory(String id) {
    final inUse = _expenses.any((e) => e.categoryId == id);
    if (inUse) {
      return false;            
    }
    _categories.removeWhere((category) => category.id == id);
    _saveCategories();
    notifyListeners();
    return true;
  }

  // Delete a subcategory
  bool deleteSubCategory(String id) {
    final inUse = _expenses.any((e) => e.subcategoryId == id);
    if (inUse) {
      return false;            
    }
    _subcategories.removeWhere((subcategory) => subcategory.id == id);
    _saveSubcategories();
    notifyListeners();
    return true;
  }

  String generateCategoryId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String generateSubcategoryId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String generateExpenseId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  void _saveCategories() {
  storage.setItem(
    'categories',
    jsonEncode(_categories.map((c) => c.toJson()).toList()),
  );
}

void _saveSubcategories() {
  storage.setItem(
    'subcategories',
    jsonEncode(_subcategories.map((s) => s.toJson()).toList()),
  );
}
/*
  void removeTimeEntry(String id) {
    _timeEntries.removeWhere((timeEntry) => timeEntry.id == id);
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }*/
}
