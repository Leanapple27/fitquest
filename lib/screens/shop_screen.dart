import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/fq_audio_service.dart';
import '../theme/fq_animations.dart';

class ShopScreen extends StatefulWidget {
  final AppState appState;

  const ShopScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _xpToConvert = 200;

  final List<Map<String, dynamic>> _pets = [
    {
      'id': 'baby_dragon',
      'emoji': '🐲',
      'name': 'Blaze the Fire Dragon',
      'house': 'Ignis House',
      'desc': 'Breathes motivational sparks & boosts sprint XP by 1.2x!',
      'price': 120,
    },
    {
      'id': 'aqua_dolphin',
      'emoji': '🐬',
      'name': 'Splash the Wave Dolphin',
      'house': 'Aqua House',
      'desc': 'Swims with agility & doubles hydration quest rewards!',
      'price': 120,
    },
    {
      'id': 'terra_golem',
      'emoji': '🗿',
      'name': 'Rocky the Stone Golem',
      'house': 'Terra House',
      'desc': 'Unbreakable defense & grants 1 Free Streak Freeze per week!',
      'price': 150,
    },
    {
      'id': 'sky_falcon',
      'emoji': '🦅',
      'name': 'Zephyr the Sky Falcon',
      'house': 'Vayu House',
      'desc': 'Flies with wind speed & reveals hidden FitMap hotspots!',
      'price': 150,
    },
  ];

  final List<Map<String, dynamic>> _frames = [
    {
      'id': 'neon_cyber',
      'name': 'Cyber Neon Halo',
      'color': Color(0xFF00F5D4),
      'desc': 'Glowing cyberpunk avatar ring for active runners.',
      'price': 80,
    },
    {
      'id': 'gold_flame',
      'name': 'Golden Sunfire Crest',
      'color': Color(0xFFF59E0B),
      'desc': 'Flaming aura earned by consistent daily movers.',
      'price': 120,
    },
    {
      'id': 'diamond_aura',
      'name': 'Diamond Champion Ring',
      'color': Color(0xFF38BDF8),
      'desc': 'Glistening crystalline border for league champions.',
      'price': 180,
    },
    {
      'id': 'royal_crown',
      'name': 'Royal Sovereign Halo',
      'color': Color(0xFFEC4899),
      'desc': 'Mythic crown displaying your legendary fitness tier.',
      'price': 250,
    },
  ];

  // 5 Real User Stickers from WhatsApp
  final List<Map<String, dynamic>> _stickers = [
    {
      'id': 'sticker_shocked_anim',
      'assetPath': 'assets/stickers/animated sticker 1.webp',
      'name': 'Shocked Anime Star',
      'tag': 'ANIMATED 🔥',
      'price': 40,
    },
    {
      'id': 'sticker_energetic_1',
      'assetPath': 'assets/stickers/19e47b09-b3bb-47a6-a92a-fa94b8edc160.webp',
      'name': 'Super Energetic',
      'tag': 'POPULAR ⭐',
      'price': 35,
    },
    {
      'id': 'sticker_cheer_2',
      'assetPath': 'assets/stickers/a0575e8a-f7c5-4791-83e6-47891e76834a.webp',
      'name': 'Victory Cheer',
      'tag': 'RARE 💎',
      'price': 40,
    },
    {
      'id': 'sticker_fighter_3',
      'assetPath': 'assets/stickers/b43e3c2f-d2a4-4e80-9b4a-ffc12274e847.webp',
      'name': 'Hero Fighter',
      'tag': 'WARRIOR ⚔️',
      'price': 45,
    },
    {
      'id': 'sticker_champ_4',
      'assetPath': 'assets/stickers/f081235a-f4bd-4540-9cc1-1f5196ab87d1.webp',
      'name': 'Power Champ',
      'tag': 'LEGENDARY 👑',
      'price': 50,
    },
  ];

  final List<Map<String, dynamic>> _schoolPerks = [
    {
      'id': 'canteen_smoothie',
      'emoji': '🥤',
      'name': 'Canteen Healthy Fruit Pass',
      'desc': 'Redeemable at School Canteen for fresh banana/apple smoothie.',
      'price': 150,
    },
    {
      'id': 'pe_free_choice',
      'emoji': '⚽',
      'name': 'PE Sports Choice Pass',
      'desc': 'Choose your favorite sport/game for one entire PE period.',
      'price': 200,
    },
    {
      'id': 'house_jersey_badge',
      'emoji': '👕',
      'name': 'House Championship Badge',
      'desc': 'Digital & physical badge pinned on school sports day.',
      'price': 250,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _convertXp() {
    if (widget.appState.xp < _xpToConvert) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough XP to convert! Complete more quests to earn XP.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final success = widget.appState.convertXpToCoins(_xpToConvert);
    if (success) {
      FQAudioService().playXpGain();
      setState(() {});

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Conversion Successful!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF151B3D)),
              ),
              const SizedBox(height: 8),
              Text(
                'Converted $_xpToConvert XP into +${(_xpToConvert / 10).floor()} FitCoins!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: const Color(0xFF00F5D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('AWESOME ⚡', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _handleBuy(String itemId, int price, String category, String itemName) {
    if (widget.appState.fitCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need $price FitCoins! Convert more XP to get coins.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final success = widget.appState.buyShopItem(itemId, price, category);
    if (success) {
      FQAudioService().playXpGain();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Unlocked $itemName! Ready in Chat & Profile.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.appState;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: FQBounce(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF151B3D)),
        ),
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded, color: Color(0xFF302B63), size: 22),
            SizedBox(width: 8),
            Text(
              'FitQuest Shop',
              style: TextStyle(color: Color(0xFF151B3D), fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Live Coin Pill
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00F5D4), width: 1.2),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '${app.fitCoins} Coins',
                  style: const TextStyle(
                    color: Color(0xFF00F5D4),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF302B63),
          indicatorWeight: 3,
          labelColor: const Color(0xFF302B63),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          tabs: const [
            Tab(text: '🏷️ Stickers'),
            Tab(text: '🐾 Pets'),
            Tab(text: '🖼️ Frames'),
            Tab(text: '🎒 School'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. XP to Coin Converter Header Card (Spacious & Clean)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: _buildXpConverterCard(app),
          ),

          // 2. Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStickersTab(app),
                _buildPetsTab(app),
                _buildFramesTab(app),
                _buildSchoolTab(app),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpConverterCard(AppState app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF302B63).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.currency_exchange_rounded, color: Color(0xFF00F5D4), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'XP ➔ FITCOIN BANK',
                    style: TextStyle(
                      color: Color(0xFF00F5D4),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'Available: ${app.xp} XP',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Preset Chips & Convert Button
          Row(
            children: [
              ...[100, 250, 500].map((amt) {
                final isSel = _xpToConvert == amt;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FQBounce(
                    onTap: () => setState(() => _xpToConvert = amt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF00F5D4) : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$amt XP',
                        style: TextStyle(
                          color: isSel ? const Color(0xFF0F0C29) : Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              FQBounce(
                onTap: _convertXp,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5D4), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Get +${(_xpToConvert / 10).floor()} Coins 🪙',
                    style: const TextStyle(
                      color: Color(0xFF0F0C29),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickersTab(AppState app) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: _stickers.length,
      itemBuilder: (ctx, i) {
        final sticker = _stickers[i];
        final isUnlocked = app.unlockedStickers.contains(sticker['id']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              width: isUnlocked ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Sticker Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFFF1F5F9),
                  child: Image.asset(
                    sticker['assetPath'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('🏷️', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sticker['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF151B3D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sticker['tag'] as String,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'IN CHAT ✓',
                    style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => _handleBuy(
                    sticker['id'] as String,
                    sticker['price'] as int,
                    'sticker',
                    sticker['name'] as String,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: const Color(0xFF00F5D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '${sticker['price']} 🪙',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPetsTab(AppState app) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: _pets.length,
      itemBuilder: (ctx, i) {
        final pet = _pets[i];
        final isUnlocked = app.unlockedPets.contains(pet['id']);
        final isEquipped = app.activePet == pet['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped ? const Color(0xFF00F5D4) : const Color(0xFFE2E8F0),
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(pet['emoji'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF151B3D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet['desc'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('ACTIVE ✓', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900, fontSize: 10.5)),
                )
              else if (isUnlocked)
                ElevatedButton(
                  onPressed: () => app.equipPet(pet['id'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('EQUIP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                )
              else
                ElevatedButton(
                  onPressed: () => _handleBuy(pet['id'] as String, pet['price'] as int, 'pet', pet['name'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0C29),
                    foregroundColor: const Color(0xFF00F5D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('${pet['price']} 🪙', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFramesTab(AppState app) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: _frames.length,
      itemBuilder: (ctx, i) {
        final frame = _frames[i];
        final isUnlocked = app.unlockedFrames.contains(frame['id']);
        final isEquipped = app.activeFrame == frame['id'];
        final color = frame['color'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped ? color : const Color(0xFFE2E8F0),
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                  color: color.withValues(alpha: 0.15),
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Color(0xFF151B3D), size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      frame['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF151B3D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      frame['desc'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('EQUIPPED', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900, fontSize: 10.5)),
                )
              else if (isUnlocked)
                ElevatedButton(
                  onPressed: () => app.equipFrame(frame['id'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('EQUIP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                )
              else
                ElevatedButton(
                  onPressed: () => _handleBuy(frame['id'] as String, frame['price'] as int, 'frame', frame['name'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F0C29),
                    foregroundColor: const Color(0xFF00F5D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('${frame['price']} 🪙', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchoolTab(AppState app) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: _schoolPerks.length,
      itemBuilder: (ctx, i) {
        final perk = _schoolPerks[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(perk['emoji'] as String, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perk['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF151B3D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      perk['desc'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _handleBuy(perk['id'] as String, perk['price'] as int, 'school', perk['name'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF302B63),
                  foregroundColor: const Color(0xFF00F5D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('${perk['price']} 🪙', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
  }
}
