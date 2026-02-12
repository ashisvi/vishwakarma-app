/// Sample location data for profile setup dropdowns.
/// Replace with API or full dataset for production.
class ProfileSetupData {
  ProfileSetupData._();

  static const List<String> states = [
    'Uttar Pradesh',
    'Bihar',
    'Madhya Pradesh',
    'Rajasthan',
    'Maharashtra',
    'West Bengal',
    'Odisha',
    'Jharkhand',
    'Chhattisgarh',
    'Haryana',
    'Punjab',
    'Gujarat',
    'Karnataka',
    'Tamil Nadu',
    'Andhra Pradesh',
  ];

  static List<String> districtsFor(String? state) {
    if (state == null || state.isEmpty) return [];
    // Sample districts per state (subset for demo)
    const map = {
      'Uttar Pradesh': ['Lucknow', 'Varanasi', 'Prayagraj', 'Kanpur', 'Agra'],
      'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur', 'Darbhanga'],
      'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain'],
      'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
      'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri', 'Asansol'],
      'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur', 'Sambalpur'],
      'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Hazaribagh'],
      'Chhattisgarh': ['Raipur', 'Bilaspur', 'Durg', 'Korba', 'Rajnandgaon'],
      'Haryana': ['Chandigarh', 'Faridabad', 'Gurugram', 'Hisar', 'Rohtak'],
      'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala', 'Bathinda'],
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
      'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
      'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool'],
    };
    return map[state] ?? [];
  }

  static List<String> blocksFor(String? district) {
    if (district == null || district.isEmpty) return [];
    // Sample blocks (tehsils) - same list for any district for demo
    return [
      'Block A',
      'Block B',
      'Block C',
      'Block D',
      'Block E',
    ];
  }

  static List<String> villagesFor(String? block) {
    if (block == null || block.isEmpty) return [];
    return [
      'Village 1',
      'Village 2',
      'Village 3',
      'Village 4',
      'Village 5',
    ];
  }
}
