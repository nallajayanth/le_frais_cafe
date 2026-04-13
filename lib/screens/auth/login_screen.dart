import 'package:flutter/material.dart';
import '../auth/otp_screen.dart';

// ── Country data model ────────────────────────────────────────────────────────
class _Country {
  final String flag;
  final String name;
  final String dialCode;
  const _Country(this.flag, this.name, this.dialCode);
}

// ── Complete country list ─────────────────────────────────────────────────────
const List<_Country> _allCountries = [
  _Country('🇦🇫', 'Afghanistan', '+93'),
  _Country('🇦🇱', 'Albania', '+355'),
  _Country('🇩🇿', 'Algeria', '+213'),
  _Country('🇦🇩', 'Andorra', '+376'),
  _Country('🇦🇴', 'Angola', '+244'),
  _Country('🇦🇬', 'Antigua & Barbuda', '+1268'),
  _Country('🇦🇷', 'Argentina', '+54'),
  _Country('🇦🇲', 'Armenia', '+374'),
  _Country('🇦🇺', 'Australia', '+61'),
  _Country('🇦🇹', 'Austria', '+43'),
  _Country('🇦🇿', 'Azerbaijan', '+994'),
  _Country('🇧🇸', 'Bahamas', '+1242'),
  _Country('🇧🇭', 'Bahrain', '+973'),
  _Country('🇧🇩', 'Bangladesh', '+880'),
  _Country('🇧🇧', 'Barbados', '+1246'),
  _Country('🇧🇾', 'Belarus', '+375'),
  _Country('🇧🇪', 'Belgium', '+32'),
  _Country('🇧🇿', 'Belize', '+501'),
  _Country('🇧🇯', 'Benin', '+229'),
  _Country('🇧🇹', 'Bhutan', '+975'),
  _Country('🇧🇴', 'Bolivia', '+591'),
  _Country('🇧🇦', 'Bosnia & Herzegovina', '+387'),
  _Country('🇧🇼', 'Botswana', '+267'),
  _Country('🇧🇷', 'Brazil', '+55'),
  _Country('🇧🇳', 'Brunei', '+673'),
  _Country('🇧🇬', 'Bulgaria', '+359'),
  _Country('🇧🇫', 'Burkina Faso', '+226'),
  _Country('🇧🇮', 'Burundi', '+257'),
  _Country('🇨🇻', 'Cabo Verde', '+238'),
  _Country('🇰🇭', 'Cambodia', '+855'),
  _Country('🇨🇲', 'Cameroon', '+237'),
  _Country('🇨🇦', 'Canada', '+1'),
  _Country('🇨🇫', 'Central African Republic', '+236'),
  _Country('🇹🇩', 'Chad', '+235'),
  _Country('🇨🇱', 'Chile', '+56'),
  _Country('🇨🇳', 'China', '+86'),
  _Country('🇨🇴', 'Colombia', '+57'),
  _Country('🇰🇲', 'Comoros', '+269'),
  _Country('🇨🇬', 'Congo', '+242'),
  _Country('🇨🇩', 'Congo (DRC)', '+243'),
  _Country('🇨🇷', 'Costa Rica', '+506'),
  _Country('🇭🇷', 'Croatia', '+385'),
  _Country('🇨🇺', 'Cuba', '+53'),
  _Country('🇨🇾', 'Cyprus', '+357'),
  _Country('🇨🇿', 'Czech Republic', '+420'),
  _Country('🇩🇰', 'Denmark', '+45'),
  _Country('🇩🇯', 'Djibouti', '+253'),
  _Country('🇩🇲', 'Dominica', '+1767'),
  _Country('🇩🇴', 'Dominican Republic', '+1809'),
  _Country('🇪🇨', 'Ecuador', '+593'),
  _Country('🇪🇬', 'Egypt', '+20'),
  _Country('🇸🇻', 'El Salvador', '+503'),
  _Country('🇬🇶', 'Equatorial Guinea', '+240'),
  _Country('🇪🇷', 'Eritrea', '+291'),
  _Country('🇪🇪', 'Estonia', '+372'),
  _Country('🇸🇿', 'Eswatini', '+268'),
  _Country('🇪🇹', 'Ethiopia', '+251'),
  _Country('🇫🇯', 'Fiji', '+679'),
  _Country('🇫🇮', 'Finland', '+358'),
  _Country('🇫🇷', 'France', '+33'),
  _Country('🇬🇦', 'Gabon', '+241'),
  _Country('🇬🇲', 'Gambia', '+220'),
  _Country('🇬🇪', 'Georgia', '+995'),
  _Country('🇩🇪', 'Germany', '+49'),
  _Country('🇬🇭', 'Ghana', '+233'),
  _Country('🇬🇷', 'Greece', '+30'),
  _Country('🇬🇩', 'Grenada', '+1473'),
  _Country('🇬🇹', 'Guatemala', '+502'),
  _Country('🇬🇳', 'Guinea', '+224'),
  _Country('🇬🇼', 'Guinea-Bissau', '+245'),
  _Country('🇬🇾', 'Guyana', '+592'),
  _Country('🇭🇹', 'Haiti', '+509'),
  _Country('🇭🇳', 'Honduras', '+504'),
  _Country('🇭🇺', 'Hungary', '+36'),
  _Country('🇮🇸', 'Iceland', '+354'),
  _Country('🇮🇳', 'India', '+91'),
  _Country('🇮🇩', 'Indonesia', '+62'),
  _Country('🇮🇷', 'Iran', '+98'),
  _Country('🇮🇶', 'Iraq', '+964'),
  _Country('🇮🇪', 'Ireland', '+353'),
  _Country('🇮🇱', 'Israel', '+972'),
  _Country('🇮🇹', 'Italy', '+39'),
  _Country('🇯🇲', 'Jamaica', '+1876'),
  _Country('🇯🇵', 'Japan', '+81'),
  _Country('🇯🇴', 'Jordan', '+962'),
  _Country('🇰🇿', 'Kazakhstan', '+7'),
  _Country('🇰🇪', 'Kenya', '+254'),
  _Country('🇰🇮', 'Kiribati', '+686'),
  _Country('🇰🇵', 'Korea (North)', '+850'),
  _Country('🇰🇷', 'Korea (South)', '+82'),
  _Country('🇽🇰', 'Kosovo', '+383'),
  _Country('🇰🇼', 'Kuwait', '+965'),
  _Country('🇰🇬', 'Kyrgyzstan', '+996'),
  _Country('🇱🇦', 'Laos', '+856'),
  _Country('🇱🇻', 'Latvia', '+371'),
  _Country('🇱🇧', 'Lebanon', '+961'),
  _Country('🇱🇸', 'Lesotho', '+266'),
  _Country('🇱🇷', 'Liberia', '+231'),
  _Country('🇱🇾', 'Libya', '+218'),
  _Country('🇱🇮', 'Liechtenstein', '+423'),
  _Country('🇱🇹', 'Lithuania', '+370'),
  _Country('🇱🇺', 'Luxembourg', '+352'),
  _Country('🇲🇬', 'Madagascar', '+261'),
  _Country('🇲🇼', 'Malawi', '+265'),
  _Country('🇲🇾', 'Malaysia', '+60'),
  _Country('🇲🇻', 'Maldives', '+960'),
  _Country('🇲🇱', 'Mali', '+223'),
  _Country('🇲🇹', 'Malta', '+356'),
  _Country('🇲🇭', 'Marshall Islands', '+692'),
  _Country('🇲🇷', 'Mauritania', '+222'),
  _Country('🇲🇺', 'Mauritius', '+230'),
  _Country('🇲🇽', 'Mexico', '+52'),
  _Country('🇫🇲', 'Micronesia', '+691'),
  _Country('🇲🇩', 'Moldova', '+373'),
  _Country('🇲🇨', 'Monaco', '+377'),
  _Country('🇲🇳', 'Mongolia', '+976'),
  _Country('🇲🇪', 'Montenegro', '+382'),
  _Country('🇲🇦', 'Morocco', '+212'),
  _Country('🇲🇿', 'Mozambique', '+258'),
  _Country('🇲🇲', 'Myanmar', '+95'),
  _Country('🇳🇦', 'Namibia', '+264'),
  _Country('🇳🇷', 'Nauru', '+674'),
  _Country('🇳🇵', 'Nepal', '+977'),
  _Country('🇳🇱', 'Netherlands', '+31'),
  _Country('🇳🇿', 'New Zealand', '+64'),
  _Country('🇳🇮', 'Nicaragua', '+505'),
  _Country('🇳🇪', 'Niger', '+227'),
  _Country('🇳🇬', 'Nigeria', '+234'),
  _Country('🇲🇰', 'North Macedonia', '+389'),
  _Country('🇳🇴', 'Norway', '+47'),
  _Country('🇴🇲', 'Oman', '+968'),
  _Country('🇵🇰', 'Pakistan', '+92'),
  _Country('🇵🇼', 'Palau', '+680'),
  _Country('🇵🇸', 'Palestine', '+970'),
  _Country('🇵🇦', 'Panama', '+507'),
  _Country('🇵🇬', 'Papua New Guinea', '+675'),
  _Country('🇵🇾', 'Paraguay', '+595'),
  _Country('🇵🇪', 'Peru', '+51'),
  _Country('🇵🇭', 'Philippines', '+63'),
  _Country('🇵🇱', 'Poland', '+48'),
  _Country('🇵🇹', 'Portugal', '+351'),
  _Country('🇶🇦', 'Qatar', '+974'),
  _Country('🇷🇴', 'Romania', '+40'),
  _Country('🇷🇺', 'Russia', '+7'),
  _Country('🇷🇼', 'Rwanda', '+250'),
  _Country('🇰🇳', 'Saint Kitts & Nevis', '+1869'),
  _Country('🇱🇨', 'Saint Lucia', '+1758'),
  _Country('🇻🇨', 'Saint Vincent & Grenadines', '+1784'),
  _Country('🇼🇸', 'Samoa', '+685'),
  _Country('🇸🇲', 'San Marino', '+378'),
  _Country('🇸🇹', 'São Tomé & Príncipe', '+239'),
  _Country('🇸🇦', 'Saudi Arabia', '+966'),
  _Country('🇸🇳', 'Senegal', '+221'),
  _Country('🇷🇸', 'Serbia', '+381'),
  _Country('🇸🇨', 'Seychelles', '+248'),
  _Country('🇸🇱', 'Sierra Leone', '+232'),
  _Country('🇸🇬', 'Singapore', '+65'),
  _Country('🇸🇰', 'Slovakia', '+421'),
  _Country('🇸🇮', 'Slovenia', '+386'),
  _Country('🇸🇧', 'Solomon Islands', '+677'),
  _Country('🇸🇴', 'Somalia', '+252'),
  _Country('🇿🇦', 'South Africa', '+27'),
  _Country('🇸🇸', 'South Sudan', '+211'),
  _Country('🇪🇸', 'Spain', '+34'),
  _Country('🇱🇰', 'Sri Lanka', '+94'),
  _Country('🇸🇩', 'Sudan', '+249'),
  _Country('🇸🇷', 'Suriname', '+597'),
  _Country('🇸🇪', 'Sweden', '+46'),
  _Country('🇨🇭', 'Switzerland', '+41'),
  _Country('🇸🇾', 'Syria', '+963'),
  _Country('🇹🇼', 'Taiwan', '+886'),
  _Country('🇹🇯', 'Tajikistan', '+992'),
  _Country('🇹🇿', 'Tanzania', '+255'),
  _Country('🇹🇭', 'Thailand', '+66'),
  _Country('🇹🇱', 'Timor-Leste', '+670'),
  _Country('🇹🇬', 'Togo', '+228'),
  _Country('🇹🇴', 'Tonga', '+676'),
  _Country('🇹🇹', 'Trinidad & Tobago', '+1868'),
  _Country('🇹🇳', 'Tunisia', '+216'),
  _Country('🇹🇷', 'Turkey', '+90'),
  _Country('🇹🇲', 'Turkmenistan', '+993'),
  _Country('🇹🇻', 'Tuvalu', '+688'),
  _Country('🇺🇬', 'Uganda', '+256'),
  _Country('🇺🇦', 'Ukraine', '+380'),
  _Country('🇦🇪', 'United Arab Emirates', '+971'),
  _Country('🇬🇧', 'United Kingdom', '+44'),
  _Country('🇺🇸', 'United States', '+1'),
  _Country('🇺🇾', 'Uruguay', '+598'),
  _Country('🇺🇿', 'Uzbekistan', '+998'),
  _Country('🇻🇺', 'Vanuatu', '+678'),
  _Country('🇻🇪', 'Venezuela', '+58'),
  _Country('🇻🇳', 'Vietnam', '+84'),
  _Country('🇾🇪', 'Yemen', '+967'),
  _Country('🇿🇲', 'Zambia', '+260'),
  _Country('🇿🇼', 'Zimbabwe', '+263'),
];

// ── Login Screen ──────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  _Country _selectedCountry =
      _allCountries.firstWhere((c) => c.dialCode == '+91'); // Default India

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber:
                '${_selectedCountry.dialCode} ${_phoneController.text}',
          ),
        ),
      );
    }
  }

  // ── Country picker bottom sheet ───────────────────────────────────────────
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: _selectedCountry,
        onSelect: (country) {
          setState(() => _selectedCountry = country);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Stack(
        children: [
          // ── Background hero image ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1605330360341-3d7ca0221382?q=80&w=1000&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xFFEFECE7),
                    BlendMode.hardLight,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.6),
                      const Color(0xFFF7F6F2),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // ── Form card ────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E5C3A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_cafe_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sign In to Le Frais',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1A17),
                            fontFamily: 'Georgia',
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "We'll send you a one-time code to\nverify.",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5C5850),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // NAME field
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'NAME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A7670),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'John Doe',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB3AFA8),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: 20),

                        // PHONE NUMBER field
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'PHONE NUMBER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A7670),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Country code picker button
                            GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCountry.flag,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.dialCode,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E5C3A),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: Color(0xFF1E5C3A),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Phone number input
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submitForm(),
                                decoration: InputDecoration(
                                  hintText: '98765 43210',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFFB3AFA8),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFEAEAEA),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Phone is required'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // SEND OTP button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5C3A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'SEND OTP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.grey[300])),
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9A9690),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 28,
                                    color: Color(0xFF1C1A17)),
                                label: const Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1A17),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  side: BorderSide(
                                      color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(28),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.apple_rounded,
                                    size: 22,
                                    color: Color(0xFF1C1A17)),
                                label: const Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1A17),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  side: BorderSide(
                                      color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(28),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Terms
                        const Text(
                          'By signing in, you agree to our',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A7670),
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E5C3A),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(text: 'Terms of Service'),
                              TextSpan(
                                text: ' & ',
                                style:
                                    TextStyle(color: Color(0xFF7A7670)),
                              ),
                              TextSpan(text: 'Privacy Policy'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Country Picker Bottom Sheet ───────────────────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  final _Country selected;
  final ValueChanged<_Country> onSelect;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<_Country> _filtered = _allCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _allCountries;
      } else {
        _filtered = _allCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query) ||
              c.flag.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Handle ─────────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDD9D3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Country',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    color: Color(0xFF1C1A17),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF6A6865),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1C1A17),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by country name or code…',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0AEAA),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1E5C3A),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFB0AEAA),
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Result count ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} countries',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A9690),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Country list ───────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final country = _filtered[i];
                      final isSelected =
                          country.dialCode == widget.selected.dialCode &&
                          country.name == widget.selected.name;
                      return _buildCountryTile(country, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryTile(_Country country, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onSelect(country);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E5C3A).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF1E5C3A).withValues(alpha: 0.25),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Flag
            Text(
              country.flag,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 14),
            // Country name
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1E5C3A)
                      : const Color(0xFF1C1A17),
                ),
              ),
            ),
            // Dial code chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E5C3A)
                    : const Color(0xFFF0EFEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                country.dialCode,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF4A4845),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1E5C3A),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No countries found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1A17),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different name\nor dial code like "+91"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9A9690),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
