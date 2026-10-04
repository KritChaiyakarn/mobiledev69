import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/pet_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart'; // เพิ่มบรรทัดนี้
import '../models/pet_model.dart';
import '../models/care_log_model.dart';
import 'add_pet_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthViewModel>().token;
      context.read<PetViewModel>().loadPets(token);
    });
  }

  void _showAddCareLogDialog(Pet pet) {
    final titleController = TextEditingController();
    final typeController = TextEditingController(text: 'Vaccine');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('เพิ่มการดูแลให้ ${pet.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'หัวข้อการดูแล (เช่น ฉีดวัคซีน)'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'ประเภท (Vaccine, Grooming, Vet)'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'บันทึกเพิ่มเติม'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final token = context.read<AuthViewModel>().token;
                final log = CareLog(
                  pet: pet.id!,
                  activityType: typeController.text,
                  title: titleController.text,
                  notes: notesController.text,
                  logDate: DateTime.now().toString().split(' ')[0],
                );
                await context.read<PetViewModel>().addCareLog(token, log);
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final petVM = context.watch<PetViewModel>();
    final themeVM = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 PetCare Log'),
        actions: [
          // ปุ่มสลับ Dark Mode / Light Mode
          IconButton(
            icon: Icon(themeVM.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'สลับธีม',
            onPressed: () => themeVM.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => petVM.loadPets(authVM.token),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- ส่วนค้นหาและกรองข้อมูล (Search & Filter UI) ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อ หรือชนิดสัตว์เลี้ยง...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) => petVM.setSearchQuery(val),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'สุนัข', 'แมว', 'นก', 'อื่นๆ'].map((species) {
                      final isSelected = petVM.selectedSpecies == species;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(species),
                          selected: isSelected,
                          onSelected: (_) => petVM.setSelectedSpecies(species),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- ส่วนแสดงรายการสัตว์เลี้ยงที่ผ่านการกรองแล้ว ---
          Expanded(
            child: petVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : petVM.filteredPets.isEmpty
                    ? const Center(child: Text('ไม่พบรายการสัตว์เลี้ยง'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: petVM.filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = petVM.filteredPets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: const CircleAvatar(child: Icon(Icons.pets)),
                              title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${pet.species} ${pet.breed != null ? "• ${pet.breed}" : ""}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => petVM.deletePet(authVM.token, pet.id!),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('รายการการดูแล:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextButton.icon(
                                        onPressed: () => _showAddCareLogDialog(pet),
                                        icon: const Icon(Icons.add),
                                        label: const Text('เพิ่มกิจกรรม'),
                                      ),
                                    ],
                                  ),
                                ),
                                if (pet.careLogs.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('ยังไม่มีประวัติการดูแล'),
                                  )
                                else
                                  ...pet.careLogs.map((log) {
                                    return CheckboxListTile(
                                      title: Text(
                                        log.title,
                                        style: TextStyle(
                                          decoration: log.isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      subtitle: Text('${log.activityType} • ${log.logDate}'),
                                      value: log.isCompleted,
                                      onChanged: (val) {
                                        if (val != null) {
                                          petVM.toggleCareLog(authVM.token, log.id!, val);
                                        }
                                      },
                                      secondary: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () => petVM.deleteCareLog(authVM.token, log.id!),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddPetDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสัตว์เลี้ยง'),
      ),
    );
  }
}