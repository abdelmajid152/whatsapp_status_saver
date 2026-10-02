import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

typedef AppIconData = List<List<dynamic>>;

/// Single place for every icon in the app (Hugeicons, stroke rounded).
abstract final class AppIcons {
  static const status = HugeIcons.strokeRoundedDashedLineCircle;
  static const business = HugeIcons.strokeRoundedStore01;
  static const saved = HugeIcons.strokeRoundedDownload04;
  static const settings = HugeIcons.strokeRoundedSettings02;
  static const refresh = HugeIcons.strokeRoundedRefresh;

  static const image = HugeIcons.strokeRoundedImage02;
  static const video = HugeIcons.strokeRoundedVideo01;
  static const brokenImage = HugeIcons.strokeRoundedImageNotFound01;
  static const brokenVideo = HugeIcons.strokeRoundedVideoOff;

  static const download = HugeIcons.strokeRoundedDownload01;
  static const done = HugeIcons.strokeRoundedTick02;
  static const success = HugeIcons.strokeRoundedCheckmarkCircle02;
  static const error = HugeIcons.strokeRoundedAlert02;
  static const delete = HugeIcons.strokeRoundedDelete02;
  static const share = HugeIcons.strokeRoundedShare08;

  static const play = HugeIcons.strokeRoundedPlay;
  static const pause = HugeIcons.strokeRoundedPause;
  static const back10 = HugeIcons.strokeRoundedGoBackward10Sec;
  static const forward10 = HugeIcons.strokeRoundedGoForward10Sec;
  static const volume = HugeIcons.strokeRoundedVolumeHigh;
  static const mute = HugeIcons.strokeRoundedVolumeOff;

  static const folder = HugeIcons.strokeRoundedFolder01;
  static const folderOpen = HugeIcons.strokeRoundedFolderOpen;
  static const lock = HugeIcons.strokeRoundedSecurityLock;
  static const shield = HugeIcons.strokeRoundedShield01;
  static const theme = HugeIcons.strokeRoundedPaintBoard;
  static const language = HugeIcons.strokeRoundedTranslate;
  static const help = HugeIcons.strokeRoundedHelpCircle;
  static const info = HugeIcons.strokeRoundedInformationCircle;
  static const privacy = HugeIcons.strokeRoundedSecurityCheck;
  static const mail = HugeIcons.strokeRoundedMail01;
  static const copy = HugeIcons.strokeRoundedCopy01;

  /// Hugeicons don't auto-mirror, so pick the arrow for the reading direction.
  static AppIconData back(BuildContext context) => _rtl(context)
      ? HugeIcons.strokeRoundedArrowRight01
      : HugeIcons.strokeRoundedArrowLeft01;

  static AppIconData forward(BuildContext context) => _rtl(context)
      ? HugeIcons.strokeRoundedArrowLeft01
      : HugeIcons.strokeRoundedArrowRight01;

  static bool _rtl(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;
}
