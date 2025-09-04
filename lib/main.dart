// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PdvApp());
}

class PdvApp extends StatelessWidget {
  const PdvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV - Protótipo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      ),
      home: const HomePage(),
    );
  }
}

final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description = '',
  });

  final String id;
  final String name;
  double price;
  int stock;
  String? imageUrl;
  String description;
}

class CartItem {
  CartItem({required this.product, required this.quantity});
  final Product product;
  int quantity;
  double get total => product.price * quantity;
}

/* PAGINA INICIAL*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _products = [
    Product(
      id: 'n1',
      name: 'Notebook Gamer',
      price: 7500.00,
      stock: 5,
      imageUrl:
          'https://i.zst.com.br/thumbs/12/9/36/41204782.jpg',
      description:
          'Notebook Gamer com processador potente, placa de vídeo dedicada, SSD rápido e sistema de resfriamento otimizado. Perfeito para jogos e edição.',
    ),
 
  ];

  final List<CartItem> _cart = [];

  void _openDrawerAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddProductPage(onSave: _addProduct)),
    );
  }

  void _addProduct(Product p) {
    setState(() {
      _products.add(p);
    });
  }

  void _addToCart(Product p) {
    if (p.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto sem estoque')),
      );
      return;
    }

    setState(() {
      final existing = _cart.where((c) => c.product.id == p.id);
      if (existing.isNotEmpty) {
        existing.first.quantity += 1;
      } else {
        _cart.add(CartItem(product: p, quantity: 1));
      }
      p.stock -= 1;
    });
  }

  double get _cartTotal => _cart.fold(0.0, (s, c) => s + c.total);

  void _openCart() async {
    final finished = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => CartPage(cart: _cart)),
    );
    if (finished == true) {
      setState(() {
        _cart.clear();
      });
    }
  }

  void _openProductDetail(Product p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ProductDetailDialog(
          product: p,
          onAdd: () {
            Navigator.of(context).pop();
            _addToCart(p);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        leading: Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          );
        }),
        title: const SizedBox.shrink(),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Color(0xFFDDDDDD)),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openDrawerAddProduct();
                  },
                  child: const Align(
                      alignment: Alignment.centerLeft, child: Text('Cadastrar novo produto')),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Align(alignment: Alignment.centerLeft, child: Text('Sair')),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            const Text('Produtos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('Nenhum produto cadastrado'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 150,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, i) {
                        final p = _products[i];
                        return GestureDetector(
                          onTap: () => _openProductDetail(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x11000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: p.imageUrl != null
                                          ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                                          : Container(
                                              color: const Color(0xFFEDEDED),
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(currency.format(p.price),
                                        style: const TextStyle(fontSize: 13)),
                                    ElevatedButton(
                                      onPressed: p.stock > 0 ? () => _addToCart(p) : null,
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                      ),
                                      child: const Text('Adicionar', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                )
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _cart.isEmpty ? null : _openCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8F3F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Finalizar • ${currency.format(_cartTotal)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* Detalhes do produto*/

class ProductDetailDialog extends StatelessWidget {
  const ProductDetailDialog({super.key, required this.product, required this.onAdd});
  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (product.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.imageUrl!, width: 80, height: 80, fit: BoxFit.cover),
                  )
                else
                  Container(width: 80, height: 80, color: const Color(0xFFEDEDED)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 6),
            Text(product.description),
            const SizedBox(height: 12),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(currency.format(product.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F8F3F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Confirmar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* adicionar produto */

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, required this.onSave});
  final void Function(Product) onSave;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');
  final _img = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _img.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0.0,
      stock: int.tryParse(_stock.text) ?? 0,
      imageUrl: _img.text.trim().isEmpty ? null : _img.text.trim(),
      description: _desc.text.trim(),
    );

    widget.onSave(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar produto'),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(label: Text('NOME'), filled: true, fillColor: Colors.white),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(label: Text('Valor'), filled: true, fillColor: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _img,
                decoration: const InputDecoration(label: Text('URL imagem'), filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(label: Text('Descrição (estoque)'), filled: true, fillColor: Colors.white),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe estoque';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Estoque inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(label: Text('Descrição'), filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F8F3F)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text('Cancelar'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/* Cartao e pagamento */

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.cart});
  final List<CartItem> cart;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get total => widget.cart.fold(0.0, (s, c) => s + c.total);

  void _goToCheckout() async {
    final finished = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => CheckoutPage(total: total)),
    );
    if (finished == true) {
      // volta sinalizando finalizado
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            Expanded(
              child: widget.cart.isEmpty
                  ? const Center(child: Text('Carrinho vazio'))
                  : ListView.separated(
                      itemCount: widget.cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = widget.cart[i];
                        return ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: item.product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(item.product.imageUrl!, width: 56, fit: BoxFit.cover),
                                )
                              : Container(width: 56, color: const Color(0xFFEDEDED)),
                          title: Text(item.product.name),
                          subtitle: Text(currency.format(item.product.price)),
                          trailing: SizedBox(
                            width: 110,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      item.quantity -= 1;
                                      item.product.stock += 1;
                                      if (item.quantity <= 0) widget.cart.removeAt(i);
                                    });
                                  },
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (item.product.stock <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sem estoque')));
                                      return;
                                    }
                                    setState(() {
                                      item.quantity += 1;
                                      item.product.stock -= 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Text('Total: ${currency.format(total)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.cart.isEmpty ? null : _goToCheckout,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F8F3F)),
                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text('Confirmar')),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text('Cancelar')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/* Checkout */

enum PaymentMethod { pix, cardDebit, cardCredit, cash }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.total});
  final double total;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _method = PaymentMethod.pix;

  void _pay() {
    // apenas simula pagamento / registro
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ConfirmationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(alignment: Alignment.centerLeft, child: Text('Pix', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(height: 12),
                // QR placeholder (poderia usar um pacote para gerar QR real)
                Container(
                  width: 200,
                  height: 200,
                  color: const Color(0xFFEEEFF0),
                  child: const Center(child: Icon(Icons.qr_code, size: 80, color: Colors.black26)),
                ),
                const SizedBox(height: 18),
                ToggleButtonTile(
                  label: 'Cartão débito',
                  selected: _method == PaymentMethod.cardDebit,
                  onTap: () => setState(() => _method = PaymentMethod.cardDebit),
                  borderColor: Colors.green,
                ),
                const SizedBox(height: 8),
                ToggleButtonTile(
                  label: 'Cartão Crédito',
                  selected: _method == PaymentMethod.cardCredit,
                  onTap: () => setState(() => _method = PaymentMethod.cardCredit),
                  borderColor: Colors.blue,
                ),
                const SizedBox(height: 8),
                ToggleButtonTile(
                  label: 'Dinheiro',
                  selected: _method == PaymentMethod.cash,
                  onTap: () => setState(() => _method = PaymentMethod.cash),
                  borderColor: Colors.orange,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F8F3F),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('Pagar • ${currency.format(widget.total)}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleButtonTile extends StatelessWidget {
  const ToggleButtonTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.borderColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? borderColor : const Color(0xFFDDDDDD)),
          color: selected ? borderColor.withValues(alpha:0.06) : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text(label)),
      ),
    );
  }
}

/* confirmaçao */

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concluído'),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Compra concluida com sucesso!', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              // volta para a raiz (home)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F8F3F)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Text('Recomeçar'),
            ),
          )
        ]),
      ),
    );
  }
}
