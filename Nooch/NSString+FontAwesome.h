//
//  NSString+FontAwesome.h
//
//  Copyright (c) 2012 Alex Usbergo. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//

#import <Foundation/Foundation.h>

static NSString *const kFontAwesomeFamilyName = @"FontAwesome";

/**
 @abstract FontAwesome Icons.
 */
typedef NS_ENUM(NSInteger, FAIcon) {
	FAGlass,
	FAMusic,
	FASearch,
	FAEnvelopeO,
	FAHeart,
	FAStar,
	FAStarO,
	FAUser,
	FAFilm,
	FAThLarge,
	FATh,
	FAThList,
	FACheck,
	FATimes,
	FASearchPlus,
	FASearchMinus,
	FAPowerOff,
	FASignal,
	FACog,
	FATrashO,
	FAHome,
	FAFileO,
	FAClockO,
	FARoad,
	FADownload,
	FAArrowCircleODown,
	FAArrowCircleOUp,
	FAInbox,
	FAPlayCircleO,
	FARepeat,
	FARefresh,
	FAListAlt,
	FALock,
	FAFlag,
	FAHeadphones,
	FAVolumeOff,
	FAVolumeDown,
	FAVolumeUp,
	FAQrcode,
	FABarcode,
	FATag,
	FATags,
	FABook,
	FABookmark,
	FAPrint,
	FACamera,
	FAFont,
	FABold,
	FAItalic,
	FATextHeight,
	FATextWidth,
	FAAlignLeft,
	FAAlignCenter,
	FAAlignRight,
	FAAlignJustify,
	FAList,
	FAOutdent,
	FAIndent,
	FAVideoCamera,
	FAPictureO,
	FAPencil,
	FAMapMarker,
	FAAdjust,
	FATint,
	FAPencilSquareO,
	FAShareSquareO,
	FACheckSquareO,
	FAArrows,
	FAStepBackward,
	FAFastBackward,
	FABackward,
	FAPlay,
	FAPause,
	FAStop,
	FAForward,
	FAFastForward,
	FAStepForward,
	FAEject,
	FAChevronLeft,
	FAChevronRight,
	FAPlusCircle,
	FAMinusCircle,
	FATimesCircle,
	FACheckCircle,
	FAQuestionCircle,
	FAInfoCircle,
	FACrosshairs,
	FATimesCircleO,
	FACheckCircleO,
	FABan,
	FAArrowLeft,
	FAArrowRight,
	FAArrowUp,
	FAArrowDown,
	FAShare,
	FAExpand,
	FACompress,
	FAPlus,
	FAMinus,
	FAAsterisk,
	FAExclamationCircle,
	FAGift,
	FALeaf,
	FAFire,
	FAEye,
	FAEyeSlash,
	FAExclamationTriangle,
	FAPlane,
	FACalendar,
	FARandom,
	FAComment,
	FAMagnet,
	FAChevronUp,
	FAChevronDown,
	FARetweet,
	FAShoppingCart,
	FAFolder,
	FAFolderOpen,
	FAArrowsV,
	FAArrowsH,
	FABarChartO,
	FATwitterSquare,
	FAFacebookSquare,
	FACameraRetro,
	FAKey,
	FACogs,
	FAComments,
	FAThumbsOUp,
	FAThumbsODown,
	FAStarHalf,
	FAHeartO,
	FASignOut,
	FALinkedinSquare,
	FAThumbTack,
	FAExternalLink,
	FASignIn,
	FATrophy,
	FAGithubSquare,
	FAUpload,
	FALemonO,
	FAPhone,
	FASquareO,
	FABookmarkO,
	FAPhoneSquare,
	FATwitter,
	FAFacebook,
	FAGithub,
	FAUnlock,
	FACreditCard,
	FARss,
	FAHddO,
	FABullhorn,
	FABell,
	FACertificate,
	FAHandORight,
	FAHandOLeft,
	FAHandOUp,
	FAHandODown,
	FAArrowCircleLeft,
	FAArrowCircleRight,
	FAArrowCircleUp,
	FAArrowCircleDown,
	FAGlobe,
	FAWrench,
	FATasks,
	FAFilter,
	FABriefcase,
	FAArrowsAlt,
	FAUsers,
	FALink,
	FACloud,
	FAFlask,
	FAScissors,
	FAFilesO,
	FAPaperclip,
	FAFloppyO,
	FASquare,
	FABars,
	FAListUl,
	FAListOl,
	FAStrikethrough,
	FAUnderline,
	FATable,
	FAMagic,
	FATruck,
	FAPinterest,
	FAPinterestSquare,
	FAGooglePlusSquare,
	FAGooglePlus,
	FAMoney,
	FACaretDown,
	FACaretUp,
	FACaretLeft,
	FACaretRight,
	FAColumns,
	FASort,
	FASortAsc,
	FASortDesc,
	FAEnvelope,
	FALinkedin,
	FAUndo,
	FAGavel,
	FATachometer,
	FACommentO,
	FACommentsO,
	FABolt,
	FASitemap,
	FAUmbrella,
	FAClipboard,
	FALightbulbO,
	FAExchange,
	FACloudDownload,
	FACloudUpload,
	FAUserMd,
	FAStethoscope,
	FASuitcase,
	FABellO,
	FACoffee,
	FACutlery,
	FAFileTextO,
	FABuildingO,
	FAHospitalO,
	FAAmbulance,
	FAMedkit,
	FAFighterJet,
	FABeer,
	FAHSquare,
	FAPlusSquare,
	FAAngleDoubleLeft,
	FAAngleDoubleRight,
	FAAngleDoubleUp,
	FAAngleDoubleDown,
	FAAngleLeft,
	FAAngleRight,
	FAAngleUp,
	FAAngleDown,
	FADesktop,
	FALaptop,
	FATablet,
	FAMobile,
	FACircleO,
	FAQuoteLeft,
	FAQuoteRight,
	FASpinner,
	FACircle,
	FAReply,
	FAGithubAlt,
	FAFolderO,
	FAFolderOpenO,
	FASmileO,
	FAFrownO,
	FAMehO,
	FAGamepad,
	FAKeyboardO,
	FAFlagO,
	FAFlagCheckered,
	FATerminal,
	FACode,
	FAReplyAll,
	FAMailReplyAll,
	FAStarHalfO,
	FALocationArrow,
	FACrop,
	FACodeFork,
	FAChainBroken,
	FAQuestion,
	FAInfo,
	FAExclamation,
	FASuperscript,
	FASubscript,
	FAEraser,
	FAPuzzlePiece,
	FAMicrophone,
	FAMicrophoneSlash,
	FAShield,
	FACalendarO,
	FAFireExtinguisher,
	FARocket,
	FAMaxcdn,
	FAChevronCircleLeft,
	FAChevronCircleRight,
	FAChevronCircleUp,
	FAChevronCircleDown,
	FAHtml5,
	FACss3,
	FAAnchor,
	FAUnlockAlt,
	FABullseye,
	FAEllipsisH,
	FAEllipsisV,
	FARssSquare,
	FAPlayCircle,
	FATicket,
	FAMinusSquare,
	FAMinusSquareO,
	FALevelUp,
	FALevelDown,
	FACheckSquare,
	FAPencilSquare,
	FAExternalLinkSquare,
	FAShareSquare,
	FACompass,
	FACaretSquareODown,
	FACaretSquareOUp,
	FACaretSquareORight,
	FAEur,
	FAGbp,
	FAUsd,
	FAInr,
	FAJpy,
	FARub,
	FAKrw,
	FABtc,
	FAFile,
	FAFileText,
	FASortAlphaAsc,
	FASortAlphaDesc,
	FASortAmountAsc,
	FASortAmountDesc,
	FASortNumericAsc,
	FASortNumericDesc,
	FAThumbsUp,
	FAThumbsDown,
	FAYoutubeSquare,
	FAYoutube,
	FAXing,
	FAXingSquare,
	FAYoutubePlay,
	FADropbox,
	FAStackOverflow,
	FAInstagram,
	FAFlickr,
	FAAdn,
	FABitbucket,
	FABitbucketSquare,
	FATumblr,
	FATumblrSquare,
	FALongArrowDown,
	FALongArrowUp,
	FALongArrowLeft,
	FALongArrowRight,
	FAApple,
	FAWindows,
	FAAndroid,
	FALinux,
	FADribbble,
	FASkype,
	FAFoursquare,
	FATrello,
	FAFemale,
	FAMale,
	FAGittip,
	FASunO,
	FAMoonO,
	FAArchive,
	FABug,
	FAVk,
	FAWeibo,
	FARenren,
	FAPagelines,
	FAStackExchange,
	FAArrowCircleORight,
	FAArrowCircleOLeft,
	FACaretSquareOLeft,
	FADotCircleO,
	FAWheelchair,
	FAVimeoSquare,
	FATry,
	FAPlusSquareO,
    
    /* FontAwesome ver 4.1.0 */
	FAautomobile,
	FAbank,
	FAbehance,
	FAbehanceSquare,
	FAbomb,
	FAbuilding,
	FAcab,
	FAcar,
	FAchild,
	FAcircleONotch,
	FAcircleThin,
	FAcodepen,
	FAcube,
	FAcubes,
	FAdatabase,
	FAdelicious,
	FAdeviantart,
	FAdigg,
	FAdrupal,
	FAempire,
	FAenvelopeSquare,
	FAfax,
	FAfileArchiveO,
	FAfileAudioO,
	FAfileCodeO,
	FAfileExcelO,
	FAfileImageO,
	FAfileMovieO,
	FAfilePdfO,
	FAfilePhotoO,
	FAfilePictureO,
	FAfilePowerpointO,
	FAfileSoundO,
	FAfileVideoO,
	FAfileWordO,
	FAfileZipO,
	FAge,
	FAgit,
	FAgitSquare,
	FAgoogle,
	FAgraduationCap,
	FAhackerNews,
	FAheader,
	FAhistory,
	FAinstitution,
	FAjoomla,
	FAjsfiddle,
	FAlanguage,
	FAlifeBouy,
	FAlifeRing,
	FAlifeSaver,
	FAmortarBoard,
	FAopenid,
	FApaperPlane,
	FApaperPlaneO,
	FAparagraph,
	FApaw,
	FApiedPiper,
	FApiedPiperalt,
	FApiedPipersquare,
	FAqq,
	FAra,
	FArebel,
	FArecycle,
	FAreddit,
	FAredditSquare,
	FAsend,
	FAsendO,
	FAshareAlt,
	FAshareAltSquare,
	FAslack,
	FAsliders,
	FAsoundcloud,
	FAspaceShuttle,
	FAspoon,
	FAspotify,
	FAsteam,
	FAsteamSquare,
	FAstumbleupon,
	FAstumbleuponCircle,
	FAsupport,
	FAtaxi,
	FAtencentWeibo,
	FAtree,
	FAuniversity,
	FAvine,
	FAwechat,
	FAweixin,
	FAwordpress,
	FAyahoo
};



@interface NSString (FontAwesome)

/**
 @abstract Returns the correct enum for a font-awesome icon.
 @discussion The list of identifiers can be found here: http://fortawesome.github.com/Font-Awesome/#all-icons
 */
+ (FAIcon)fontAwesomeEnumForIconIdentifier:(NSString*)string;

/**
 @abstract Returns the font-awesome character associated to the icon enum passed as argument
 */
+ (NSString*)fontAwesomeIconStringForEnum:(FAIcon)value;

/*
 @abstract Returns the font-awesome character associated to the font-awesome identifier.
 @discussion The list of identifiers can be found here: http://fortawesome.github.com/Font-Awesome/#all-icons
 */
+ (NSString*)fontAwesomeIconStringForIconIdentifier:(NSString*)identifier;

@end