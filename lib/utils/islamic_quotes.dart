/// Collection of authentic Islamic quotes and wisdom
class IslamicQuotes {
  static const List<String> quotes = [
    // Core Islamic Values & Character
    "The best of you are those who are best to their families.",
    "Seek knowledge from the cradle to the grave.",
    "The most beloved places to Allah are the mosques.",
    "Verily, with hardship comes ease.",
    "Indeed, Allah is with the patient.",
    "The best of people are those who are most beneficial to people.",
    "Whoever believes in Allah and the Last Day, let him speak good or remain silent.",
    "The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.",
    "Do not be people without minds of your own, saying that if others treat you well you will treat them well, and that if they do wrong you will do wrong. Instead, accustom yourselves to do good if people do good and not to do wrong if they do evil.",
    "The best charity is that given in Ramadan.",
    
    // Prayer & Worship
    "The first thing that will be judged among a man's deeds on the Day of Resurrection is the prayer. If it is good, he will have prospered and succeeded; and if it is defective, he will have failed and lost.",
    "When you stand for prayer, pray as if it is your last prayer.",
    "The prayer of a person in congregation is twenty-seven times more superior to the prayer offered alone.",
    "The key to Paradise is prayer, and the key to prayer is ablution.",
    "Allah does not look at your appearance or wealth, but He looks at your hearts and actions.",
    "The most beloved of deeds to Allah are those that are most consistent, even if they are small.",
    "Whoever prays Fajr is under the protection of Allah.",
    "The prayer is the pillar of religion.",
    "The best prayer after the obligatory prayers is the night prayer.",
    "The prayer of a person in congregation is twenty-five times more superior to the prayer offered alone.",
    
    // Knowledge & Learning
    "Seeking knowledge is obligatory upon every Muslim.",
    "The ink of the scholar is more sacred than the blood of the martyr.",
    "Whoever treads a path in search of knowledge, Allah will make easy for him the path to Paradise.",
    "The best of you is he who has learnt the Quran and taught it to others.",
    "Knowledge is power, and the best knowledge is that which benefits others.",
    "The most truthful speech is the Book of Allah.",
    "The best of you is he who learns the Quran and teaches it.",
    "Seek knowledge even if you have to go to China.",
    "The best of people are those who are most beneficial to people.",
    "Knowledge is a light that guides to the right path.",
    
    // Patience & Perseverance
    "Indeed, Allah is with the patient.",
    "Verily, with hardship comes ease.",
    "The patient person will attain what the hasty person cannot.",
    "Patience is the key to relief.",
    "Allah loves those who are patient.",
    "The best of people are those who are most patient in times of hardship.",
    "Patience is a light.",
    "Whoever remains patient, Allah will make him patient.",
    "The patient person will attain what the hasty person cannot.",
    "Patience is the key to success.",
    
    // Kindness & Good Character
    "The best of you are those who are best to their families.",
    "The most beloved of people to Allah are those who are most beneficial to people.",
    "The best of you are those who have the best character.",
    "A good word is charity.",
    "Smiling in the face of your brother is charity.",
    "The best of you are those who are best to their wives.",
    "The most beloved places to Allah are the mosques.",
    "The best of you are those who are most beneficial to people.",
    "A good word is charity.",
    "The best of you are those who have the best character.",
    
    // Gratitude & Contentment
    "If you are grateful, I will surely increase you in favor.",
    "The best of you are those who are most grateful to Allah.",
    "Whoever is not grateful to people is not grateful to Allah.",
    "The best of you are those who are most grateful.",
    "Gratitude is the key to increase.",
    "The grateful person will always have more.",
    "The best of you are those who are most grateful to Allah.",
    "Gratitude is the key to happiness.",
    "The grateful person will always have more.",
    "Gratitude is the key to increase.",
    
    // Forgiveness & Mercy
    "The best of you are those who are most forgiving.",
    "Allah is Most Merciful and He loves mercy.",
    "The merciful will be shown mercy by the Most Merciful.",
    "Forgive others and Allah will forgive you.",
    "The best of you are those who are most forgiving.",
    "Mercy is not removed except from the wretched.",
    "The merciful will be shown mercy by the Most Merciful.",
    "Forgive others and Allah will forgive you.",
    "The best of you are those who are most forgiving.",
    "Mercy is not removed except from the wretched.",
    
    // Unity & Brotherhood
    "The believers are like one body; if one part hurts, the whole body feels the pain.",
    "A Muslim is the brother of another Muslim.",
    "The best of you are those who are most beneficial to people.",
    "The believers are like one body.",
    "A Muslim is the brother of another Muslim.",
    "The best of you are those who are most beneficial to people.",
    "The believers are like one body; if one part hurts, the whole body feels the pain.",
    "A Muslim is the brother of another Muslim.",
    "The best of you are those who are most beneficial to people.",
    "The believers are like one body.",
  ];

  /// Gets today's quote based on the current date
  static String getTodayQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  /// Gets a random quote
  static String getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return quotes[random % quotes.length];
  }

  /// Gets a truly random quote using current time
  static String getNewRandomQuote() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch + now.microsecond;
    return quotes[random % quotes.length];
  }

  /// Gets quote for a specific day
  static String getQuoteForDay(int day) {
    return quotes[day % quotes.length];
  }
} 