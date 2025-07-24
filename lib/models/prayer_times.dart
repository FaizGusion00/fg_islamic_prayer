class PrayerTimes {
  final String? fajr;
  final String? sunrise;
  final String? dhuhr;
  final String? asr;
  final String? sunset;
  final String? maghrib;
  final String? isha;
  final String? imsak;
  final String? midnight;
  final String? firstthird;
  final String? lastthird;
  final DateInfo? date;
  final LocationInfo? location;

  PrayerTimes({
    this.fajr,
    this.sunrise,
    this.dhuhr,
    this.asr,
    this.sunset,
    this.maghrib,
    this.isha,
    this.imsak,
    this.midnight,
    this.firstthird,
    this.lastthird,
    this.date,
    this.location,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>? ?? {};
    
    return PrayerTimes(
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      sunset: _cleanTime(timings['Sunset']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      imsak: _cleanTime(timings['Imsak']),
      midnight: _cleanTime(timings['Midnight']),
      firstthird: _cleanTime(timings['Firstthird']),
      lastthird: _cleanTime(timings['Lastthird']),
      date: json['date'] != null ? DateInfo.fromJson(json['date']) : null,
      location: json['meta'] != null ? LocationInfo.fromJson(json['meta']) : null,
    );
  }

  static String? _cleanTime(dynamic time) {
    if (time == null) return null;
    String timeStr = time.toString();
    // Remove timezone info if present (e.g., "05:30 (+03)" -> "05:30")
    if (timeStr.contains('(')) {
      timeStr = timeStr.split('(')[0].trim();
    }
    return timeStr;
  }

  Map<String, dynamic> toJson() {
    return {
      'timings': {
        'Fajr': fajr,
        'Sunrise': sunrise,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Sunset': sunset,
        'Maghrib': maghrib,
        'Isha': isha,
        'Imsak': imsak,
        'Midnight': midnight,
        'Firstthird': firstthird,
        'Lastthird': lastthird,
      },
      'date': date?.toJson(),
      'meta': location?.toJson(),
    };
  }

  String? get dhuha {
    // If API provides Dhuha, use it. Otherwise, calculate as 25 minutes after sunrise.
    if (allTimes.any((pt) => pt.name.toLowerCase() == 'dhuha' && pt.time != null)) {
      return allTimes.firstWhere((pt) => pt.name.toLowerCase() == 'dhuha').time;
    }
    if (sunrise != null) {
      final sunriseParts = sunrise!.split(':');
      if (sunriseParts.length == 2) {
        int hour = int.tryParse(sunriseParts[0]) ?? 0;
        int minute = int.tryParse(sunriseParts[1]) ?? 0;
        minute += 25;
        if (minute >= 60) {
          hour += 1;
          minute -= 60;
        }
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }
    return null;
  }

  List<PrayerTime> get mainPrayers => [
    PrayerTime('Fajr', fajr, 'Dawn Prayer'),
    PrayerTime('Sunrise', sunrise, 'Sunrise'),
    PrayerTime('Dhuha', dhuha, 'Forenoon (Duha)'),
    PrayerTime('Dhuhr', dhuhr, 'Noon Prayer'),
    PrayerTime('Asr', asr, 'Afternoon Prayer'),
    PrayerTime('Maghrib', maghrib, 'Sunset Prayer'),
    PrayerTime('Isha', isha, 'Night Prayer'),
  ];

  List<PrayerTime> get allTimes => [
    PrayerTime('Imsak', imsak, 'Pre-dawn'),
    PrayerTime('Fajr', fajr, 'Dawn Prayer'),
    PrayerTime('Sunrise', sunrise, 'Sunrise'),
    PrayerTime('Dhuhr', dhuhr, 'Noon Prayer'),
    PrayerTime('Asr', asr, 'Afternoon Prayer'),
    PrayerTime('Sunset', sunset, 'Sunset'),
    PrayerTime('Maghrib', maghrib, 'Sunset Prayer'),
    PrayerTime('Isha', isha, 'Night Prayer'),
    PrayerTime('Midnight', midnight, 'Islamic Midnight'),
  ];
}

class PrayerTime {
  final String name;
  final String? time;
  final String description;

  PrayerTime(this.name, this.time, this.description);

  bool get isValid => time != null && time!.isNotEmpty;
}

class DateInfo {
  final String? readable;
  final String? timestamp;
  final HijriDate? hijri;
  final GregorianDate? gregorian;

  DateInfo({
    this.readable,
    this.timestamp,
    this.hijri,
    this.gregorian,
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      readable: json['readable'],
      timestamp: json['timestamp'],
      hijri: json['hijri'] != null ? HijriDate.fromJson(json['hijri']) : null,
      gregorian: json['gregorian'] != null ? GregorianDate.fromJson(json['gregorian']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readable': readable,
      'timestamp': timestamp,
      'hijri': hijri?.toJson(),
      'gregorian': gregorian?.toJson(),
    };
  }
}

class HijriDate {
  final String? date;
  final String? format;
  final String? day;
  final String? weekday;
  final String? month;
  final String? year;
  final HijriMonth? monthInfo;

  HijriDate({
    this.date,
    this.format,
    this.day,
    this.weekday,
    this.month,
    this.year,
    this.monthInfo,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'],
      format: json['format'],
      day: json['day'],
      weekday: json['weekday']?['en'],
      month: json['month']?['number']?.toString(),
      year: json['year'],
      monthInfo: json['month'] != null ? HijriMonth.fromJson(json['month']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'format': format,
      'day': day,
      'weekday': {'en': weekday},
      'month': monthInfo?.toJson(),
      'year': year,
    };
  }
}

class HijriMonth {
  final int? number;
  final String? en;
  final String? ar;

  HijriMonth({this.number, this.en, this.ar});

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'],
      en: json['en'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'en': en,
      'ar': ar,
    };
  }
}

class GregorianDate {
  final String? date;
  final String? format;
  final String? day;
  final String? weekday;
  final String? month;
  final String? year;

  GregorianDate({
    this.date,
    this.format,
    this.day,
    this.weekday,
    this.month,
    this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      format: json['format'],
      day: json['day'],
      weekday: json['weekday']?['en'],
      month: json['month']?['en'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'format': format,
      'day': day,
      'weekday': {'en': weekday},
      'month': {'en': month},
      'year': year,
    };
  }
}

class LocationInfo {
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final String? method;
  final String? school;

  LocationInfo({
    this.latitude,
    this.longitude,
    this.timezone,
    this.method,
    this.school,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      method: json['method']?['name'],
      school: json['school'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'method': {'name': method},
      'school': school,
    };
  }
}