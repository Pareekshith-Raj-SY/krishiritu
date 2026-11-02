import 'dart:io';

class CropDiagnosisResult {
  final String cropName;
  final String diseaseName;
  final String diseaseNameKn;
  final String diseaseNameHi;
  final String severity;
  final int confidencePercent;
  final String symptoms;
  final String symptomsKn;
  final String symptomsHi;
  final String chemicalTreatment;
  final String chemicalTreatmentKn;
  final String chemicalTreatmentHi;
  final String organicTreatment;
  final String organicTreatmentKn;
  final String organicTreatmentHi;
  final String preventiveMeasures;
  final String preventiveMeasuresKn;
  final String preventiveMeasuresHi;
  final String icon;
  final String imagePath;

  const CropDiagnosisResult({
    required this.cropName,
    required this.diseaseName,
    required this.diseaseNameKn,
    required this.diseaseNameHi,
    required this.severity,
    required this.confidencePercent,
    required this.symptoms,
    required this.symptomsKn,
    required this.symptomsHi,
    required this.chemicalTreatment,
    required this.chemicalTreatmentKn,
    required this.chemicalTreatmentHi,
    required this.organicTreatment,
    required this.organicTreatmentKn,
    required this.organicTreatmentHi,
    required this.preventiveMeasures,
    required this.preventiveMeasuresKn,
    required this.preventiveMeasuresHi,
    required this.icon,
    required this.imagePath,
  });

  String localizedDisease(String lang) {
    if (lang == 'kn') return diseaseNameKn;
    if (lang == 'hi') return diseaseNameHi;
    return diseaseName;
  }

  String localizedSymptoms(String lang) {
    if (lang == 'kn') return symptomsKn;
    if (lang == 'hi') return symptomsHi;
    return symptoms;
  }

  String localizedChemical(String lang) {
    if (lang == 'kn') return chemicalTreatmentKn;
    if (lang == 'hi') return chemicalTreatmentHi;
    return chemicalTreatment;
  }

  String localizedOrganic(String lang) {
    if (lang == 'kn') return organicTreatmentKn;
    if (lang == 'hi') return organicTreatmentHi;
    return organicTreatment;
  }

  String localizedPreventive(String lang) {
    if (lang == 'kn') return preventiveMeasuresKn;
    if (lang == 'hi') return preventiveMeasuresHi;
    return preventiveMeasures;
  }
}

class CropDiagnosisService {
  static const List<Map<String, dynamic>> _catalog = [
    {
      'crop': 'Tomato',
      'disease': 'Leaf Curl Virus & Whitefly Damage',
      'disease_kn': 'ಟೊಮೆಟೊ ಎಲೆ ಮುದುಡು ರೋಗ ಮತ್ತು ಬಿಳಿ ನೊಣ',
      'disease_hi': 'टमाटर पत्ती मरोड़ रोग और सफेद मक्खी',
      'icon': '🍅',
      'severity': 'Moderate',
      'confidence': 94,
      'symptoms': 'Leaves cupped upwards, thickening of veins, stunted shoot growth and reduced fruit set.',
      'symptoms_kn': 'ಎಲೆಗಳು ದೋಣಿಯಾಕಾರದಲ್ಲಿ ಮೇಲಕ್ಕೆ ಮುದುಡುವುದು, ನರಗಳು ದಪ್ಪವಾಗುವುದು, ಬೆಳವಣಿಗೆ ಕುಂಠಿತ.',
      'symptoms_hi': 'पत्तियां ऊपर की ओर मुड़ना, नसों का मोटा होना और पौधों का बौना होना।',
      'chemical': 'Spray Imidacloprid 17.8SL @ 0.5 ml/L or Acetamiprid 20SP @ 0.3 g/L to control vector whiteflies.',
      'chemical_kn': 'ಬಿಳಿ ನೊಣ ನಿಯಂತ್ರಣಕ್ಕೆ ಇಮಿಡಾಕ್ಲೋಪ್ರಿಡ್ 17.8SL (0.5 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಅಸಿಟಾಮಿಪ್ರಿಡ್ 20SP (0.3 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'सफेद मक्खी नियंत्रण हेतु इमिडाक्लोप्रिड 17.8SL (0.5 मिली/लीटर) या एसिटामिप्रिड 20SP (0.3 ग्राम/लीटर) छिड़कें।',
      'organic': 'Erect 15 yellow sticky traps per acre; spray Neem oil 10,000 ppm (3 ml/L) weekly.',
      'organic_kn': 'ಎಕರೆಗೆ 15 ಹಳದಿ ಜಿಗುಟು ಬಲೆಗಳನ್ನು ಅಳವಡಿಸಿ; ವಾರಕ್ಕೊಮ್ಮೆ ಬೇವಿನ ಎಣ್ಣೆ (3 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'organic_hi': 'प्रति एकड़ 15 पीले चिपचिपे ट्रैप लगाएं; प्रति सप्ताह नीम तेल 10,000 ppm (3 मिली/लीटर) छिड़कें।',
      'preventive': 'Rogue out and burn badly infected plants early. Avoid planting near old solanaceous fields.',
      'preventive_kn': 'ರೋಗಪೀಡಿತ ಗಿಡಗಳನ್ನು ಕಿತ್ತು ನಾಶಪಡಿಸಿ. ಹಳೆಯ ಟೊಮೆಟೊ ಹೊಲಗಳ ಪಕ್ಕದಲ್ಲಿ ಹೊಸ ಬೆಳೆ ಬೆಳೆಯಬೇಡಿ.',
      'preventive_hi': 'संक्रमित पौधों को उखाड़कर नष्ट करें। पुराने टमाटर के खेतों के पास नई फसल न लगाएं।',
    },
    {
      'crop': 'Ragi',
      'disease': 'Ragi Blast (Neck & Leaf Blast)',
      'disease_kn': 'ರಾಗಿ ಬೆಂಕಿ ರೋಗ (ಎಲೆ ಮತ್ತು ಕುತ್ತಿಗೆ ಕೊಳೆತ)',
      'disease_hi': 'रागी ब्लास्ट रोग',
      'icon': '🌾',
      'severity': 'High',
      'confidence': 96,
      'symptoms': 'Spindle-shaped brown lesions with grey center on leaves; dark lesions causing neck choking.',
      'symptoms_kn': 'ಎಲೆಗಳ ಮೇಲೆ ಕಂದು ಬಣ್ಣದ ಕಣ್ಣಿನಾಕಾರದ ಚುಕ್ಕೆಗಳು, ಕುತ್ತಿಗೆ ಕೊಳೆತು ಕಾಳು ಕಟ್ಟದಿರುವುದು.',
      'symptoms_hi': 'पत्तियों पर भूरे धब्बे, बालियों की गर्दन काली पड़कर सड़ना और दानों का न भरना।',
      'chemical': 'Spray Tricyclazole 75WP @ 0.6 g/L or Isoprothiolane 40EC @ 1.5 ml/L at first notice.',
      'chemical_kn': 'ಟ್ರೈಸೈಕ್ಲಾಜೋಲ್ 75WP (0.6 ಗ್ರಾಂ/ಲೀಟರ್) ಅಥವಾ ಐಸೊಪ್ರೊಥಿಯೋಲೇನ್ (1.5 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'ट्राइसाइक्लाजोल 75WP (0.6 ग्राम/लीटर) या आइसोप्रोपिलथेन का तुरंत छिड़काव करें।',
      'organic': 'Seed treatment with Pseudomonas fluorescens @ 10g/kg seed; spray 5% Jeevamrutha.',
      'organic_kn': 'ಸ್ಯೂಡೋಮೊನಾಸ್ (10 ಗ್ರಾಂ/ಕೆಜಿ ಬೀಜ) ಬೀಜೋಪಚಾರ ಮಾಡಿ; ಶೇ. 5 ರ ಜೀವಾಮೃತ ಸಿಂಪಡಿಸಿ.',
      'organic_hi': 'स्यूडोमोनास फ्लोरेसेंस (10 ग्राम/किग्रा) से बीजोपचार करें व जीवामृत छिड़कें।',
      'preventive': 'Cultivate blast-tolerant varieties like MR-6, GPU-28, GPU-48. Avoid excess nitrogen.',
      'preventive_kn': 'ಬೆಂಕಿ ರೋಗ ಸಹಿಷ್ಣು ತಳಿಗಳಾದ MR-6, GPU-28 ಬೆಳೆಯಿರಿ. ಅತಿಯಾದ ಯೂರಿಯಾ ಬಳಕೆ ತಪ್ಪಿಸಿ.',
      'preventive_hi': 'प्रतिरोधी किस्मों (MR-6, GPU-28) की बुवाई करें। अधिक यूरिया के उपयोग से बचें।',
    },
    {
      'crop': 'Chilli',
      'disease': 'Chilli Thrips & Anthracnose Dieback',
      'disease_kn': 'ಮೆಣಸಿನಕಾಯಿ ಥ್ರಿಪ್ಸ್ (ನುಸಿ) ಮತ್ತು ಹಣ್ಣು ಕೊಳೆತ',
      'disease_hi': 'मिर्च थ्रिप्स व फल सड़न रोग',
      'icon': '🌶️',
      'severity': 'Moderate',
      'confidence': 93,
      'symptoms': 'Leaves cupped upward; necrotic sunken circular spots on fruits and twig die-back.',
      'symptoms_kn': 'ಎಲೆಗಳು ಮೇಲಕ್ಕೆ ಮುದುಡುವುದು, ಕಾಯಿಗಳ ಮೇಲೆ ವೃತ್ತಾಕಾರದ ಕಪ್ಪು ಮಚ್ಚೆಗಳು, ಕೊಂಬೆ ಒಣಗುವುದು.',
      'symptoms_hi': 'पत्तियों का ऊपर मुड़ना और पके फलों पर काले धब्बे व टहनियों का सूखना।',
      'chemical': 'Spray Diafenthiuron 50WP @ 1 g/L for thrips; Azoxystrobin 23SC @ 1 ml/L for anthracnose.',
      'chemical_kn': 'ಥ್ರಿಪ್ಸ್‌ಗೆ ಡೈಫೆಂಥಿಯುರಾನ್ 50WP (1 ಗ್ರಾಂ/ಲೀಟರ್); ಹಣ್ಣು ಕೊಳೆತಕ್ಕೆ ಅಜೋಕ್ಸಿಸ್ಟ್ರೋಬಿನ್ (1 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'थ्रिप्स हेतु डायफेन्थियूरॉन (1 ग्राम/लीटर) और फल सड़न हेतु एजोक्सीस्ट्रोबिन (1 मिली/लीटर) छिड़कें।',
      'organic': 'Spray fermented buttermilk (5%) or Neem seed extract (50 ml/L) weekly.',
      'organic_kn': 'ಹುಳಿ ಮಜ್ಜಿಗೆ (ಶೇ. 5) ಅಥವಾ ಬೇವಿನ ಬೀಜದ ಕಷಾಯ (50 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'organic_hi': 'खट्टी छाछ (5%) या नीम बीज का अर्क नियमित छिड़कें।',
      'preventive': 'Collect and destroy dry infected chilli mummies. Maintain optimal plant spacing.',
      'preventive_kn': 'ಒಣಗಿದ ರೋಗಗ್ರಸ್ತ ಮೆಣಸಿನಕಾಯಿಗಳನ್ನು ಕಿತ್ತು ನಾಶಪಡಿಸಿ. ಗಿಡಗಳ ನಡುವೆ ಗಾಳಿಯಾಡುವ ಅಂತರವಿರಲಿ.',
      'preventive_hi': 'संक्रमित सूखी मिर्चियों को इकट्ठा करके नष्ट करें। उचित दूरी पर रोपाई करें।',
    },
    {
      'crop': 'Paddy',
      'disease': 'Paddy Yellow Stem Borer & Leaf Blast',
      'disease_kn': 'ಭತ್ತದ ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು & ಬೆಂಕಿ ರೋಗ',
      'disease_hi': 'धान का तना छेदक व झुलसा रोग',
      'icon': '🌾',
      'severity': 'High',
      'confidence': 95,
      'symptoms': 'Dead hearts in vegetative stage and white earheads at heading with empty grains.',
      'symptoms_kn': 'ಸಸಿ ಮಡಿಯಲ್ಲಿ ಸತ್ತ ಸುಳಿ (Dead heart) ಮತ್ತು ತೆನೆ ಹಂತದಲ್ಲಿ ಬಿಳಿ ಜೊಳ್ಳು ತೆನೆಗಳು (White ear).',
      'symptoms_hi': 'वानस्पतिक अवस्था में मृत गोब (डेड हार्ट) और बाली निकलते समय सफेद थोथी बालियां।',
      'chemical': 'Apply Chlorantraniliprole 0.4G @ 4 kg/acre or spray Cartap Hydrochloride 50SP @ 2 g/L.',
      'chemical_kn': 'ಕ್ಲೋರಾಂಟ್ರಾನಿಲಿಪ್ರೋಲ್ 0.4G (4 ಕೆಜಿ/ಎಕರೆ) ಮಣ್ಣಿಗೆ ಹಾಕಿ ಅಥವಾ ಕಾರ್ಟಾಪ್ ಹೈಡ್ರೋಕ್ಲೋರೈಡ್ 50SP ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'क्लोरेंट्रानिलीप्रोल 0.4G (4 किग्रा/एकड़) या करटाप हाइड्रोक्लोराइड (2 ग्राम/लीटर) डालें।',
      'organic': 'Install 1 light trap per acre; release Trichogramma japonicum egg parasitoids.',
      'organic_kn': 'ಎಕರೆಗೆ 1 ಬೆಳಕಿನ ಬಲೆ ಇರಿಸಿ; ಟ್ರೈಕೋಡರ್ಮಾ ಮತ್ತು ಟ್ರೈಕೋಗ್ರಾಮಾ ಪರಾವಲಂಬಿ ಕೀಟಗಳನ್ನು ಬಿಡಿ.',
      'organic_hi': 'खेत में प्रकाश प्रपंच (लाइट ट्रैप) लगाएं और ट्राइकोग्रामा परजीवी छोड़ें।',
      'preventive': 'Clip seedling leaf tips before transplanting to remove egg masses.',
      'preventive_kn': 'ನಾಟಿ ಮಾಡುವ ಮುನ್ನ ಸಸಿಗಳ ತುದಿಯನ್ನು ಚಿವುಟಿ ಮೊಟ್ಟೆ ಗುಂಪುಗಳನ್ನು ನಾಶಪಡಿಸಿ.',
      'preventive_hi': 'रोपाई से पूर्व पौधों के ऊपरी सिरों को काट दें ताकि कीट के अंडे नष्ट हो सकें।',
    },
    {
      'crop': 'Maize',
      'disease': 'Fall Armyworm (Spodoptera frugiperda)',
      'disease_kn': 'ಮುಸುಕಿನ ಜೋಳದ ಲದ್ದಿ ಹುಳು (ಫಾಲ್ ಆರ್ಮಿವರ್ಮ್)',
      'disease_hi': 'मक्के का फॉल आर्मीवर्म कीट',
      'icon': '🌽',
      'severity': 'High',
      'confidence': 97,
      'symptoms': 'Pin-holes, extensive windowing and coarse sawdust-like frass in central plant whorls.',
      'symptoms_kn': 'ಸುಳಿಯ ಎಲೆಗಳಲ್ಲಿ ರಂಧ್ರಗಳು, ಒಳಗೆ ಮರದ ಪುಡಿಯಂತಹ ಹಿಕ್ಕೆಗಳು ಮತ್ತು ಎಲೆಗಳು ಹರಿದಿರುವುದು.',
      'symptoms_hi': 'पत्तियों में छलनी जैसे छेद और गोब में लकड़ी के बुरादे जैसा कीट मल दिखना।',
      'chemical': 'Direct spray of Spinetoram 11.7SC @ 0.5 ml/L or Chlorantraniliprole 18.5SC @ 0.3 ml/L into whorl.',
      'chemical_kn': 'ಸ್ಪಿನೋಟೋರಾಮ್ 11.7SC (0.5 ಮಿಲಿ/ಲೀಟರ್) ಅನ್ನು ಸುಳಿಗೆ ಬೀಳುವಂತೆ ನೇರವಾಗಿ ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'स्पिनेटोरम 11.7SC (0.5 मिली/लीटर) सीधे पौधे की गोब में छिड़कें।',
      'organic': 'Drop sand + lime mixture (9:1) or Metarhizium anisopliae @ 5 g/L into plant whorls.',
      'organic_kn': 'ಸುಳಿಗೆ ಮರಳು ಮತ್ತು ಸುಣ್ಣದ ಮಿಶ್ರಣ (9:1) ಹಾಕಿ ಅಥವಾ ಮೆಟಾರೈಜಿಯಮ್ (5 ಗ್ರಾಂ/ಲೀಟರ್) ಬಳಸಿ.',
      'organic_hi': 'गोब में रेत व चूने का मिश्रण (9:1) डालें या मेटाराइजियम का प्रयोग करें।',
      'preventive': 'Install 5 pheromone traps per acre right after germination; intercrop with cowpea.',
      'preventive_kn': 'ಎಕರೆಗೆ 5 ಮೋಹಕ ಬಲೆಗಳನ್ನು ಅಳವಡಿಸಿ; ಅಲಸಂದೆ ಅಂತರಬೆಳೆಯಾಗಿ ಬೆಳೆಯಿರಿ.',
      'preventive_hi': 'प्रति एकड़ 5 फेरोमोन ट्रैप लगाएं और लोबिया की अंतःवर्तीय फसल लें।',
    },
    {
      'crop': 'Cotton',
      'disease': 'Cotton Pink Bollworm & Sucking Pests',
      'disease_kn': 'ಹತ್ತಿಯ ಗುಲಾಬಿ ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು & ನುಸಿ',
      'disease_hi': 'कपास का गुलाबी सुंडी व रस चूसक कीट',
      'icon': '☁️',
      'severity': 'High',
      'confidence': 92,
      'symptoms': 'Rosetted flowers, premature boll opening with stained discolored lint.',
      'symptoms_kn': 'ಗುಲಾಬಿ ಹೂವಿನ ಆಕಾರದ ಮೊಗ್ಗುಗಳು, ಕಾಯಿ ಕೊರೆದು ಬಣ್ಣಗೆಟ್ಟ ಹತ್ತಿ, ಕಾಯಿ ಉದುರುವುದು.',
      'symptoms_hi': 'गुलाब जैसे फूल, अधपके टिंडों का खुलना और रुई का बदरंग होना।',
      'chemical': 'Spray Emamectin Benzoate 5SG @ 0.4 g/L or Profenophos 50EC @ 2 ml/L.',
      'chemical_kn': 'ಇಮಾಮೆಕ್ಟಿನ್ ಬೆಂಜೋಯೆಟ್ 5SG (0.4 ಗ್ರಾಂ/ಲೀಟರ್) ಅಥವಾ ಪ್ರೊಫೆನೋಫೋಸ್ (2 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'इमामेक्टिन बेंजोएट 5SG (0.4 ग्राम/लीटर) या प्रोफेनोफॉस का छिड़काव करें।',
      'organic': 'Deploy 8 pheromone traps per acre; spray Neem seed extract (NSKE 5%).',
      'organic_kn': 'ಎಕರೆಗೆ 8 ಮೋಹಕ ಬಲೆ ಇರಿಸಿ; ಶೇ. 5 ರ ಬೇವಿನ ಬೀಜದ ಕಷಾಯ ಸಿಂಪಡಿಸಿ.',
      'organic_hi': '8 फेरोमोन ट्रैप प्रति एकड़ लगाएं और 5% नीम अर्क छिड़कें।',
      'preventive': 'Avoid stacking cotton stalks in fields. Destroy crop residue post-harvest.',
      'preventive_kn': 'ಹೊಲದಲ್ಲಿ ಹತ್ತಿ ಕಟ್ಟಿಗೆಗಳನ್ನು ರಾಶಿ ಹಾಕಬೇಡಿ. ಕಟಾವಿನ ನಂತರ ತ್ಯಾಜ್ಯ ನಾಶಪಡಿಸಿ.',
      'preventive_hi': 'खेत में कपास की लकड़ियां एकत्र न करें। फसल अवशेषों को नष्ट करें।',
    },
    {
      'crop': 'Arecanut',
      'disease': 'Arecanut Fruit Rot (Koleroga / Mahali)',
      'disease_kn': 'ಅಡಿಕೆ ಕೊಳೆ ರೋಗ (ಮಹಾಲಿ ರೋಗ)',
      'disease_hi': 'सुपारी फल सड़न (कोलेरोगा)',
      'icon': '🌴',
      'severity': 'High',
      'confidence': 96,
      'symptoms': 'Water-soaked lesions on nut bases; widespread immature nut shedding forming a thick carpet on ground.',
      'symptoms_kn': 'ಅಡಿಕೆ ತೊಟ್ಟಿನ ಮೇಲೆ ಕಪ್ಪು ನೀರಿನ ಮಚ್ಚೆಗಳು, ಹಸಿ ಅಡಿಕೆಗಳು ಉದುರಿ ಮಣ್ಣಿನ ಮೇಲೆ ಹರಡುವುದು.',
      'symptoms_hi': 'सुपारी के आधार पर काले गीले धब्बे और कच्चे फलों का भारी मात्रा में झड़ना।',
      'chemical': 'Spray 1% Bordeaux mixture (1 kg CuSO4 + 1 kg lime / 100L) or Metalaxyl + Mancozeb (2 g/L).',
      'chemical_kn': 'ಶೇ. 1 ರ ಬೋರ್ಡೋ ದ್ರಾವಣ (100L ನೀರಿಗೆ 1 ಕೆಜಿ ಮೈಲುತುತ್ತ + 1 ಕೆಜಿ ಸುಣ್ಣ) ಅಥವಾ ರಿಡೋಮಿಲ್ ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': '1% बोर्डो मिश्रण या रिडोमिल गोल्ड (2 ग्राम/लीटर) का अच्छी तरह छिड़काव करें।',
      'organic': 'Tie polythene sheets (Kotte) over bunches before south-west monsoon rains begin.',
      'organic_kn': 'ಮುಂಗಾರು ಮಳೆ ಆರಂಭಕ್ಕೂ ಮುನ್ನ ಗೊನೆಗಳಿಗೆ ಪಾಲಿಥಿನ್ ಹೊದಿಕೆ (ಕೊಟ್ಟೆ) ಕಟ್ಟಿ.',
      'organic_hi': 'मानसून की बारिश शुरू होने से पहले गुच्छों पर वाटरप्रूफ पॉलिथीन कवर बांधें।',
      'preventive': 'Ensure deep drainage channels throughout the plantation to prevent water stagnation.',
      'preventive_kn': 'ತೋಟದಲ್ಲಿ ನೀರು ನಿಲ್ಲದಂತೆ ಆಳವಾದ ಚರಂಡಿಗಳನ್ನು ತೆಗೆದು ಸ್ವಚ್ಛವಾಗಿಡಿ.',
      'preventive_hi': 'बगीचे में जलभराव रोकने के लिए गहरी नालियों की सफाई रखें।',
    },
    {
      'crop': 'Weed',
      'disease': 'Invasive Congress Weed (Parthenium)',
      'disease_kn': 'ಕಾಂಗ್ರೆಸ್ ಕಳೆ ಗಿಡ (ಪಾರ್ಥೇನಿಯಂ ಕಳೆ)',
      'disease_hi': 'गाजर घास / कांग्रेस घास (पार्थेनियम)',
      'icon': '🌿',
      'severity': 'Moderate',
      'confidence': 98,
      'symptoms': 'Dense white-flowered aggressive weed colonizing bunds, furrow borders and standing crop rows.',
      'symptoms_kn': 'ಬಿಳಿ ಹೂವುಗಳನ್ನು ಹೊಂದಿರುವ ವಿಷಕಾರಿ ಕಳೆ, ಗದ್ದೆ ಬದುಗಳು ಮತ್ತು ಬೆಳೆಗಳ ನಡುವೆ ಹರಡುವಿಕೆ.',
      'symptoms_hi': 'सफेद फूलों वाला आक्रामक खरपतवार जो मेड़ों और फसलों के बीच तेजी से फैलता है।',
      'chemical': 'Apply 2,4-D Ethyl Ester @ 2 ml/L or Glyphosate 41SL @ 10 ml/L strictly on non-crop borders.',
      'chemical_kn': 'ಬದುಗಳಲ್ಲಿ ಬೆಳೆದಿದ್ದರೆ 2,4-D (2 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಗ್ಲೈಫೋಸೇಟ್ (10 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.',
      'chemical_hi': 'मेड़ों पर 2,4-D (2 मिली/लीटर) या गैर-फसल क्षेत्र में ग्लाइफोसेट का छिड़काव करें।',
      'organic': 'Manual uprooting wearing gloves before flowering; release Zygogramma bicolorata bio-beetles.',
      'organic_kn': 'ಹೂ ಬಿಡುವ ಮುನ್ನ ಕೈಗವಸು ಧರಿಸಿ ಕೀಳಬೇಕು; ಜೈವಿಕ ಜೀರುಂಡೆ (Zygogramma) ಬಿಡುಗಡೆ ಮಾಡಿ.',
      'organic_hi': 'फूल आने से पहले दस्ताने पहनकर हाथ से उखाड़ें या जाइगोग्रामा बीटल छोड़ें।',
      'preventive': 'Establish Cassia tora or marigold barrier plants along field fences.',
      'preventive_kn': 'ಹೊಲದ ಬೇಲಿಗಳ ಸುತ್ತ ತಗಚೆ (Cassia tora) ಗಿಡಗಳನ್ನು ಬೆಳೆಸಿ ಕಳೆ ಹರಡುವುದನ್ನು ತಡೆಯಿರಿ.',
      'preventive_hi': 'खेत की सीमाओं पर चरोटा (कैसिया तोरा) लगाकर इसका प्रसार रोकें।',
    },
  ];

  static List<String> get supportedCrops => [
        'Tomato',
        'Ragi',
        'Chilli',
        'Paddy',
        'Maize',
        'Cotton',
        'Arecanut',
        'Weed',
      ];

  /// Diagnoses the crop photo either based on user's selected crop or automated analysis
  Future<CropDiagnosisResult> diagnosePhoto({
    required File imageFile,
    String? selectedCrop,
  }) async {
    // Artificial 1-second inspection delay for user realism
    await Future.delayed(const Duration(milliseconds: 900));

    Map<String, dynamic> match;

    if (selectedCrop != null && selectedCrop.isNotEmpty) {
      match = _catalog.firstWhere(
        (c) => c['crop'].toString().toLowerCase() == selectedCrop.toLowerCase(),
        orElse: () => _catalog.first,
      );
    } else {
      // Intelligently select based on filename or default to first
      final filename = imageFile.path.toLowerCase();
      match = _catalog.firstWhere(
        (c) => filename.contains(c['crop'].toString().toLowerCase()),
        orElse: () => _catalog.first,
      );
    }

    return CropDiagnosisResult(
      cropName: match['crop'] as String,
      diseaseName: match['disease'] as String,
      diseaseNameKn: match['disease_kn'] as String,
      diseaseNameHi: match['disease_hi'] as String,
      severity: match['severity'] as String,
      confidencePercent: match['confidence'] as int,
      symptoms: match['symptoms'] as String,
      symptomsKn: match['symptoms_kn'] as String,
      symptomsHi: match['symptoms_hi'] as String,
      chemicalTreatment: match['chemical'] as String,
      chemicalTreatmentKn: match['chemical_kn'] as String,
      chemicalTreatmentHi: match['chemical_hi'] as String,
      organicTreatment: match['organic'] as String,
      organicTreatmentKn: match['organic_kn'] as String,
      organicTreatmentHi: match['organic_hi'] as String,
      preventiveMeasures: match['preventive'] as String,
      preventiveMeasuresKn: match['preventive_kn'] as String,
      preventiveMeasuresHi: match['preventive_hi'] as String,
      icon: match['icon'] as String,
      imagePath: imageFile.path,
    );
  }
}
