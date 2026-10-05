import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/pet_viewmodel.dart';

class AddPetDialog extends StatefulWidget {
  const AddPetDialog({super.key});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เพิ่มสัตว์เลี้ยงใหม่'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสัตว์เลี้ยง *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'ชนิด (เช่น สุนัข, แมว) *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'กรุณากรอกชนิด' : null,
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'สายพันธุ์'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isSubmitting = true);

                    final token = context.read<AuthViewModel>().token;
                    
                    if (token == null || token.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่พบ Token กรุณาล็อกอินใหม่อีกครั้ง')),
                        );
                        setState(() => _isSubmitting = false);
                      }
                      return;
                    }

                    final newPet = Pet(
                      name: _nameController.text.trim(),
                      species: _speciesController.text.trim(),
                      breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
                    );

                    final success = await context.read<PetViewModel>().addPet(token, newPet);

                    if (mounted) {
                      setState(() => _isSubmitting = false);
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('เพิ่มสัตว์เลี้ยงสำเร็จ!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('เพิ่มสัตว์เลี้ยงไม่สำเร็จ! กรุณาเช็ค Console หรือ Log Backend')),
                        );
                      }
                    }
                  }
                },
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('บันทึก'),
        ),
      ],
    );
  }
}