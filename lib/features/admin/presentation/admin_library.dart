import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/library_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminLibrary extends ConsumerStatefulWidget {
  const AdminLibrary({super.key});

  @override
  ConsumerState<AdminLibrary> createState() => _AdminLibraryState();
}

class _AdminLibraryState extends ConsumerState<AdminLibrary> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(libraryBooksProvider);
    final statistics = ref.watch(libraryStatisticsProvider);
    return AdminShell(
      title: 'Library Management',
      child: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _errorState(),
        data: (items) => _content(context, items, statistics),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Unable to load library books.'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            ref.invalidate(libraryBooksProvider);
            ref.invalidate(libraryStatisticsProvider);
          },
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _content(
    BuildContext context,
    List<LibraryBook> items,
    AsyncValue<LibraryStatistics> statistics,
  ) {
    final filtered = items.where((book) {
      final searchable = [
        book.title,
        book.author,
        book.isbn,
        book.category,
        book.department,
      ].join(' ').toLowerCase();
      return searchable.contains(_query.toLowerCase());
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Library management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 6),
                  Text('Manage books and circulation inventory.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openBookForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add book'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        statistics.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Statistics unavailable', style: TextStyle(color: AppColors.textSecondary)),
          data: (value) => _statistics(value),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by title, author, ISBN or department',
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          AdminCard(
            child: Center(
              child: Text(
                items.isEmpty ? 'No books have been added yet.' : 'No books match your search.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...filtered.map(_bookCard),
      ],
    );
  }

  Widget _statistics(LibraryStatistics value) => Wrap(
    spacing: 14,
    runSpacing: 14,
    children: [
      _stat('Catalog titles', value.totalBooks, Icons.menu_book_outlined, AppColors.primary),
      _stat('Available copies', value.availableBooks, Icons.check_circle_outline, AppColors.success),
      _stat('Issued copies', value.issuedBooks, Icons.assignment_outlined, const Color(0xFFB26A00)),
      _stat('Overdue', value.overdueBooks, Icons.schedule_outlined, const Color(0xFFCF4B4B)),
    ],
  );

  Widget _stat(String label, int value, IconData icon, Color color) => SizedBox(
    width: 190,
    child: AdminStatCard(label: label, value: '$value', detail: 'Current records', icon: icon, color: color),
  );

  Widget _bookCard(LibraryBook book) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AdminCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE4EFFB),
          child: Icon(Icons.menu_book_outlined, color: AppColors.primary),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${book.author}  |  ${book.category.isEmpty ? 'Uncategorized' : book.category}\n${book.department.isEmpty ? 'All departments' : book.department}  |  ${book.availableCopies}/${book.totalCopies} available'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          tooltip: 'Book actions',
          onSelected: (action) {
            if (action == 'edit') _openBookForm(book);
            if (action == 'delete') _deleteBook(book);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    ),
  );

  Future<void> _openBookForm([LibraryBook? book]) async {
    final result = await showDialog<LibraryBook>(
      context: context,
      builder: (_) => _BookFormDialog(book: book),
    );
    if (result == null) return;
    try {
      await ref.read(libraryRepositoryProvider).saveBook(result);
      _refresh(result.id.isEmpty ? 'Book added.' : 'Book updated.');
    } catch (_) {
      _showMessage('Unable to save the book.');
    }
  }

  Future<void> _deleteBook(LibraryBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Delete "${book.title}" from the library catalog?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(libraryRepositoryProvider).deleteBook(book.id);
      _refresh('Book deleted.');
    } catch (_) {
      _showMessage('Unable to delete the book.');
    }
  }

  void _refresh(String message) {
    ref.invalidate(libraryBooksProvider);
    ref.invalidate(libraryStatisticsProvider);
    _showMessage(message);
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _BookFormDialog extends StatefulWidget {
  const _BookFormDialog({this.book});
  final LibraryBook? book;

  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _isbn;
  late final TextEditingController _category;
  late final TextEditingController _department;
  late final TextEditingController _total;
  late final TextEditingController _available;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _title = TextEditingController(text: book?.title);
    _author = TextEditingController(text: book?.author);
    _isbn = TextEditingController(text: book?.isbn);
    _category = TextEditingController(text: book?.category);
    _department = TextEditingController(text: book?.department);
    _total = TextEditingController(text: book == null ? '' : '${book.totalCopies}');
    _available = TextEditingController(text: book == null ? '' : '${book.availableCopies}');
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.book == null ? 'Add library book' : 'Edit library book'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _field(_title, 'Title'),
              _field(_author, 'Author'),
              _field(_isbn, 'ISBN', required: false),
              _field(_category, 'Category', required: false),
              _field(_department, 'Department', required: false),
              Row(children: [Expanded(child: _field(_total, 'Total copies', numeric: true)), const SizedBox(width: 12), Expanded(child: _field(_available, 'Available copies', numeric: true))]),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _submit, child: const Text('Save book')),
    ],
  );

  Widget _field(TextEditingController controller, String label, {bool required = true, bool numeric = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : null,
      decoration: InputDecoration(labelText: label),
      validator: required ? (value) => value == null || value.trim().isEmpty ? '$label is required.' : null : null,
    ),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final total = int.tryParse(_total.text.trim()) ?? 0;
    final available = int.tryParse(_available.text.trim()) ?? 0;
    if (total < 1 || available < 0 || available > total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid copy counts.')));
      return;
    }
    Navigator.pop(
      context,
      LibraryBook(
        id: widget.book?.id ?? '',
        title: _title.text.trim(),
        author: _author.text.trim(),
        isbn: _isbn.text.trim(),
        category: _category.text.trim(),
        department: _department.text.trim(),
        totalCopies: total,
        availableCopies: available,
        createdAt: widget.book?.createdAt,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [_title, _author, _isbn, _category, _department, _total, _available]) {
      controller.dispose();
    }
    super.dispose();
  }
}
