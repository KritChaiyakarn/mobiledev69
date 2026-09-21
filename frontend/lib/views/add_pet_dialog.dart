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
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'ชนิด (เช่น สุนัข, แมว) *'),
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกชนิด' : null,
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
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final token = context.read<AuthViewModel>().token;
              final newPet = Pet(
                name: _nameController.text,
                species: _speciesController.text,
                breed: _breedController.text,
              );
              final success = await context.read<PetViewModel>().addPet(token, newPet);
              if (mounted && success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('เพิ่มสัตว์เลี้ยงสำเร็จ!')),
                );
              }
            }
          },
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}