import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:surat_store/core/utils/assets.dart';

import '../../../../controllers/product_controller.dart';
import '../../../../core/utils/app_formatter.dart';
import '../../../../data/model/product_model.dart';
import 'add_product_animations.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AddProductAnimations animations;

  final Color primaryBlue = const Color(0xff2563EB);
  final Color darkBlue = const Color(0xff1E40AF);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  final ProductController productController = Get.put(ProductController());

  // add product rules
  void showProductGuideDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryBlue.withAlpha(20),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.rule_folder_rounded,
                          color: primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Product Guide",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildGuideSection(
                    title: "Steps to Add Product",
                    items: const [
                      "Upload one clear product cover image",
                      "Enter unique product name",
                      "Add short product description",
                      "Enter valid positive price",
                      "Enter stock quantity",
                      "Tap save to add product",
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildGuideSection(
                    title: "Regulations",
                    items: const [
                      "Product name is mandatory",
                      "Price must be greater than zero",
                      "Stock cannot be negative",
                      "Only one cover image allowed",
                      "Avoid duplicate product names",
                      "Use high-quality product image",
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Got it",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}";

      final savedImage = await File(
        image.path,
      ).copy('${directory.path}/$fileName');

      setState(() {
        selectedImage = savedImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    animations = AddProductAnimations(controller: _animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: const Color(0xffF8FAFC),
          backgroundColor: const Color(0xffF8FAFC),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "New Product",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryBlue.withAlpha(18),
                border: Border.all(color: Colors.grey.withAlpha(50), width: 1),
              ),
              child: Center(
                child: Image.asset(
                  AppAssets.backIcon,
                  width: 22,
                  height: 22,
                  color: primaryBlue,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          actions: [
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryBlue.withAlpha(18),
                border: Border.all(color: primaryBlue.withAlpha(35), width: 1),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: showProductGuideDialog,
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              children: [
                SlideTransition(
                  position: animations.imagePickerSlide,
                  child: FadeTransition(
                    opacity: animations.imagePickerFade,
                    child: buildImagePickerUI(),
                  ),
                ),

                SlideTransition(
                  position: animations.imagePreviewSlide,
                  child: FadeTransition(
                    opacity: animations.imagePreviewFade,
                    child: buildImagePreviewRow(),
                  ),
                ),

                SlideTransition(
                  position: animations.formSlide,
                  child: FadeTransition(
                    opacity: animations.formFade,
                    child: Column(
                      children: [
                        buildTextField(
                          "Product Name",
                          nameController,
                          Icons.shopping_bag_outlined,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Product name is required";
                            }
                            return null;
                          },
                        ),

                        buildTextField(
                          "Description",
                          descController,
                          Icons.description_outlined,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                        ),

                        buildTextField(
                          "Price",
                          priceController,
                          Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final price = AppFormatter.parsePrice(value ?? "");
                            if (value == null || value.isEmpty) {
                              return "Price is required";
                            }
                            if (price <= 0) {
                              return "Enter valid positive price";
                            }
                            return null;
                          },
                        ),

                        buildTextField(
                          "Stock Quantity",
                          stockController,
                          Icons.inventory_2_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final stock = int.tryParse(value ?? "");
                            if (value == null || value.isEmpty) {
                              return "Stock is required";
                            }
                            if (stock == null || stock < 0) {
                              return "Stock cannot be negative";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SlideTransition(
                  position: animations.buttonSlide,
                  child: FadeTransition(
                    opacity: animations.buttonFade,
                    child: buildSaveButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // image picker
  Widget buildImagePickerUI() {
    return Container(
      width: double.infinity,
      height: 190,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffDBEAFE), Color(0xffEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xffBFDBFE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: showImageSourceOptions,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: primaryBlue,
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Upload Product Cover",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedImage == null
                  ? "Tap to choose a premium cover image"
                  : "Tap to replace current image",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // option gallery and camera
  void showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryBlue.withAlpha(20),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Camera"),
                      ],
                    ),
                  ),

                  // Gallery option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryBlue.withAlpha(20),
                          child: Icon(
                            Icons.photo_library_rounded,
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Gallery"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // mini image preview
  Widget buildImagePreviewRow() {
    final file = selectedImage;
    if (file == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          GestureDetector(
            onTap: openFullScreenImage,
            child: Hero(
              tag: "product_cover_preview",
              transitionOnUserGestures: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedImage = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Product Cover",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // long preview mini image
  void openFullScreenImage() {
    final file = selectedImage;
    if (file == null) return;

    Get.to(
      () => GestureDetector(
        onTap: Get.back, // outside tap close
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                // full black layer
                Positioned.fill(child: Container(color: Colors.white)),

                // image area
                Center(
                  child: GestureDetector(
                    onTap: () {}, // prevent close when tapping image
                    child: Hero(
                      tag: "product_cover_preview",
                      transitionOnUserGestures: true,
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),

                // close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      opaque: true,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 455),
    );
  }

  // all text filed
  Widget buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final bool isMultiLine = maxLines > 1;
    final bool isPriceField = hint == "Price";

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,

        // Auto comma formatter only for Price field
        inputFormatters: isPriceField
            ? [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;

                  final number = int.tryParse(
                    newValue.text.replaceAll(',', ''),
                  );
                  if (number == null) return oldValue;

                  final formatted = AppFormatter.inr.format(number);

                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }),
              ]
            : keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 10,
              top: isMultiLine ? 12 : 8,
              bottom: isMultiLine ? 40 : 8,
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primaryBlue.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryBlue, size: 20),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 64,
            minHeight: 42,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: primaryBlue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // save button
  Widget buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, darkBlue]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final product = ProductModel(
            name: nameController.text.trim(),
            description: descController.text.trim(),
            price: AppFormatter.parsePrice(priceController.text),
            stockQty: int.parse(stockController.text.trim()),
            imagePath: selectedImage?.path ?? "",
          );

          // 1. Close screen immediately (IMPORTANT)
          Navigator.pop(context);

          // 2. Then process offline/online safely
          Future.microtask(() async {
            await productController.addProduct(product);

            Get.snackbar(
              "Success",
              "Product saved successfully",
              snackPosition: SnackPosition.BOTTOM,
            );
          });
        },
        child: const Text(
          "Save Product",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  //   add product rules widget
  Widget _buildGuideSection({
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
