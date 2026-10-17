import 'package:json_annotation/json_annotation.dart';

part 'phrazzle_base.g.dart';

@JsonSerializable()
class PhraseValidationInfo {
  final bool isValid;
  final Iterable<int>? matchIndices;
  final String? wholeWordMatch;

  PhraseValidationInfo(this.isValid, {this.matchIndices, this.wholeWordMatch});

  Map<String, dynamic> toJson() => _$PhraseValidationInfoToJson(this);
  factory PhraseValidationInfo.fromJson(json) => _$PhraseValidationInfoFromJson(json);
}

class PhrazzleBase {
  /// Determines if a sub phrase is valid from a given root phrase
  static PhraseValidationInfo getPhraseMatchingInformation(String rootPhrase, String subPhrase) {
    if (subPhrase.isEmpty) return PhraseValidationInfo(false);

    // Prep phrases
    final rootPhraseTransform = rootPhrase.trim().toLowerCase();
    final subPhraseTransform = subPhrase.trim().toLowerCase();

    // Check if the sub phrase contains an uninterrupted word or phrase from the root phrase
    final wordsInRootPhrase = rootPhraseTransform.split(' ');
    final wordsInSubPhrase = subPhraseTransform.split(' ');

    String lastProcessedWord = '';
    if (wordsInSubPhrase.any(
      (final string) {
          lastProcessedWord = string;
        return wordsInRootPhrase.contains(string);
      }
    )) {
      return PhraseValidationInfo(false, wholeWordMatch: lastProcessedWord);
    }

    var isValid = true;
    var rootProcessingIndex = 0;
    final rootMatchIndices = <int>[];
    for (var subPhraseIndex = 0; subPhraseIndex < subPhraseTransform.length; subPhraseIndex++) {
      final subRoot = rootPhraseTransform.substring(rootProcessingIndex);
      final matchedCharSubRootIndex = subRoot.indexOf(subPhraseTransform[subPhraseIndex]);
      if (subPhraseTransform[subPhraseIndex] == ' ') continue;
      if (matchedCharSubRootIndex >= 0) {
        rootProcessingIndex += matchedCharSubRootIndex + 1;
        rootMatchIndices.add(rootProcessingIndex - 1);
      } else {
        isValid = false;
      }
    }
    return PhraseValidationInfo(isValid, matchIndices: rootMatchIndices);
  }

  // TODO: Remove or move to somewhere(tm)
  /// Scores a chain of sub phrases until invalid or done
  static int getNumberOfValidPhrases(String phrase, List<String> subPhrases) {
    var invalidSubPhrase = false;
    return subPhrases.fold(0, (final score, final subPhrase) {
      if (invalidSubPhrase) return score;
      final isValid = getPhraseMatchingInformation(phrase, subPhrase).isValid;
      if (isValid == false) {
        invalidSubPhrase = true;
        return score;
      }
      return score + 1;
    });
  }
}
