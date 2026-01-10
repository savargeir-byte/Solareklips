class EducationTimeline {
  static String explain(double progress) {
    if (progress < 0.3) {
      return "The Moon is beginning to move in front of the Sun.";
    } else if (progress < 0.6) {
      return "The Sun is now mostly covered. Light levels drop.";
    } else if (progress < 0.94) {
      return "Only a thin crescent of sunlight remains.";
    } else if (progress < 0.98) {
      return "This is the Diamond Ring effect — perfect for photography.";
    } else {
      return "Totality. The Sun's corona becomes visible.";
    }
  }
}
