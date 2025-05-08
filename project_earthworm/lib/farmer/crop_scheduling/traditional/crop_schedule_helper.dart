// crop_schedule_helper.dart
class CropScheduleHelper {
  static List<Map<String, String>> getScheduleForCrop(
    String cropName,
    DateTime plantingDate,
    String soilType,
  ) {
    final schedule = _getBaseCropSchedule(cropName, plantingDate);
    final soilTasks = _getSoilSpecificTasks(cropName, soilType);

    // Merge soil-specific tasks into the base schedule
    return _mergeSchedules(schedule, soilTasks);
  }

  static List<Map<String, String>> _getBaseCropSchedule(
    String cropName,
    DateTime plantingDate,
  ) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return [
          {
            'date': 'Day 1 - ${_formatDate(plantingDate)}',
            'task': 'Land preparation: Plow and level the field'
          },
          {
            'date':
                'Week 1 - ${_formatDate(plantingDate.add(const Duration(days: 7)))}',
            'task': 'Seed soaking and sowing in nursery'
          },
          {
            'date':
                'Week 3-4 - ${_formatDate(plantingDate.add(const Duration(days: 21)))}',
            'task': 'Transplanting seedlings'
          },
          {
            'date': 'Week 5-6',
            'task': 'First fertilizer application and weeding'
          },
          {'date': 'Week 8-9', 'task': 'Second fertilizer application'},
          {
            'date': 'Week 12-14',
            'task': 'Panicle initiation and flowering stage'
          },
          {'date': 'Week 16-18', 'task': 'Grain filling stage'},
          {
            'date': 'Week 20-22',
            'task': 'Harvest when 80% of grains are mature'
          },
        ];

      case 'maize':
        return [
          {
            'date': 'Day 1 - ${_formatDate(plantingDate)}',
            'task': 'Field preparation and soil testing'
          },
          {
            'date':
                'Week 1 - ${_formatDate(plantingDate.add(const Duration(days: 7)))}',
            'task': 'Direct seed sowing'
          },
          {
            'date': 'Week 2-3',
            'task': 'Monitor germination and thin seedlings'
          },
          {'date': 'Week 4-5', 'task': 'First fertilizer application'},
          {'date': 'Week 6-7', 'task': 'Weeding and pest monitoring'},
          {'date': 'Week 8-9', 'task': 'Second fertilizer application'},
          {'date': 'Week 10-12', 'task': 'Tasseling and silking stage'},
          {'date': 'Week 16-18', 'task': 'Harvest when kernels are firm'},
        ];

      case 'cotton':
        return [
          {
            'date': 'Day 1 - ${_formatDate(plantingDate)}',
            'task': 'Deep plowing and field preparation'
          },
          {
            'date':
                'Week 1 - ${_formatDate(plantingDate.add(const Duration(days: 7)))}',
            'task': 'Seed sowing'
          },
          {'date': 'Week 2-3', 'task': 'Monitor emergence and gap filling'},
          {
            'date': 'Week 4-5',
            'task': 'First fertilizer application and thinning'
          },
          {'date': 'Week 6-8', 'task': 'Weeding and inter-cultivation'},
          {
            'date': 'Week 10-12',
            'task': 'Square formation and flowering stage'
          },
          {'date': 'Week 16-20', 'task': 'Boll development stage'},
          {'date': 'Week 22-24', 'task': 'First picking of mature bolls'},
        ];

      case 'tomatoes':
        return [
          {
            'date': 'Day 1 - ${_formatDate(plantingDate)}',
            'task': 'Seedbed preparation and sowing'
          },
          {'date': 'Week 3-4', 'task': 'Transplant seedlings to main field'},
          {
            'date': 'Week 5-6',
            'task': 'Staking and first fertilizer application'
          },
          {'date': 'Week 7-8', 'task': 'Pruning and pest monitoring'},
          {'date': 'Week 9-10', 'task': 'Flowering stage and fruit set'},
          {'date': 'Week 12-14', 'task': 'First harvest of mature fruits'},
          {'date': 'Week 15-20', 'task': 'Continue harvesting periodically'},
        ];

      default:
        return [
          {
            'date': 'Day 1 - ${_formatDate(plantingDate)}',
            'task': 'Land preparation and soil testing'
          },
          {'date': 'Week 1', 'task': 'Sowing/Planting'},
          {'date': 'Week 2-3', 'task': 'Initial irrigation and fertilization'},
          {'date': 'Week 4-6', 'task': 'Weed control and pest monitoring'},
          {
            'date': 'Week 7-8',
            'task': 'Growth monitoring and disease prevention'
          },
          {
            'date': 'Week 9-12',
            'task': 'Regular irrigation and nutrient management'
          },
          {'date': 'Week 13-16', 'task': 'Pre-harvest preparation'},
          {'date': 'Final Week', 'task': 'Harvest and post-harvest handling'},
        ];
    }
  }

  static List<Map<String, String>> _getSoilSpecificTasks(
    String cropName,
    String soilType,
  ) {
    final tasks = <Map<String, String>>[];

    switch (soilType.toLowerCase()) {
      case 'clay':
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Add organic matter to improve drainage'
        });
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Deep tillage to break up compacted soil'
        });
        break;

      case 'sandy':
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Add organic matter to improve water retention'
        });
        tasks.add({
          'date': 'Growing season',
          'task': 'More frequent irrigation may be needed'
        });
        break;

      case 'loamy':
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Light tillage to maintain soil structure'
        });
        break;

      case 'silt':
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Add organic matter to improve structure'
        });
        tasks.add({
          'date': 'Pre-planting',
          'task': 'Careful irrigation to prevent surface crusting'
        });
        break;
    }

    return tasks;
  }

  static List<Map<String, String>> _mergeSchedules(
    List<Map<String, String>> baseSchedule,
    List<Map<String, String>> additionalTasks,
  ) {
    final mergedSchedule = [...baseSchedule];

    for (final task in additionalTasks) {
      // Find where to insert the additional task based on date
      final insertIndex = mergedSchedule.indexWhere(
        (scheduleItem) => scheduleItem['date'] == task['date'],
      );

      if (insertIndex >= 0) {
        // If date exists, append to task
        mergedSchedule[insertIndex]['task'] =
            '${mergedSchedule[insertIndex]['task']}; ${task['task']}';
      } else {
        // If date doesn't exist, add new entry
        mergedSchedule.add(task);
      }
    }

    // Sort schedule by date
    mergedSchedule.sort((a, b) {
      final aIsPrePlanting =
          a['date']?.toLowerCase().contains('pre-planting') ?? false;
      final bIsPrePlanting =
          b['date']?.toLowerCase().contains('pre-planting') ?? false;

      if (aIsPrePlanting != bIsPrePlanting) {
        return aIsPrePlanting ? -1 : 1;
      }

      return 0;
    });

    return mergedSchedule;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getIrrigationAdvice(String cropName, String irrigationType) {
    final baseAdvice = _getBaseIrrigationAdvice(cropName);
    final methodAdvice = _getIrrigationMethodAdvice(irrigationType);

    return '$baseAdvice $methodAdvice';
  }

  static String _getBaseIrrigationAdvice(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return 'Maintain 5-7 cm water level during vegetative stage. Drain field 10 days before harvest.';
      case 'maize':
        return 'Critical irrigation periods: knee-high stage, tasseling, and grain filling.';
      case 'cotton':
        return 'Regular irrigation during square formation and boll development.';
      case 'tomatoes':
        return 'Consistent moisture needed. Avoid wetting leaves to prevent disease.';
      default:
        return 'Maintain consistent soil moisture throughout growing season.';
    }
  }

  static String _getIrrigationMethodAdvice(String irrigationType) {
    switch (irrigationType.toLowerCase()) {
      case 'drip':
        return 'Monitor drip lines regularly for clogging. Maintain consistent pressure.';
      case 'sprinkler':
        return 'Irrigate during early morning or evening to minimize evaporation.';
      case 'flood':
        return 'Ensure proper field leveling for uniform water distribution.';
      case 'furrow':
        return 'Maintain proper furrow length and slope for efficient irrigation.';
      case 'rain-fed':
        return 'Consider supplemental irrigation during dry spells.';
      default:
        return 'Monitor soil moisture regularly and adjust irrigation accordingly.';
    }
  }

  static String getSoilPreparationAdvice(String cropName, String soilType) {
    final baseSoilAdvice = _getBaseSoilAdvice(cropName);
    final soilTypeAdvice = _getSoilTypeAdvice(soilType);

    return '$baseSoilAdvice $soilTypeAdvice';
  }

  static String _getBaseSoilAdvice(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return 'Puddle soil for better water retention. Add organic matter.';
      case 'maize':
        return 'Deep plowing recommended. Ensure good drainage.';
      case 'cotton':
        return 'Deep plowing and ridge formation required.';
      case 'tomatoes':
        return 'Well-drained soil with organic matter. Raised beds recommended.';
      default:
        return 'Prepare soil to 6-8 inches depth. Ensure good drainage.';
    }
  }

  static String _getSoilTypeAdvice(String soilType) {
    switch (soilType.toLowerCase()) {
      case 'clay':
        return 'Add organic matter to improve drainage and tilth.';
      case 'sandy':
        return 'Add organic matter to improve water retention.';
      case 'loamy':
        return 'Maintain organic matter content for optimal structure.';
      case 'silt':
        return 'Avoid overworking to prevent compaction.';
      case 'peaty':
        return 'Monitor pH and add lime if needed.';
      default:
        return 'Maintain good soil structure through proper management.';
    }
  }
}
