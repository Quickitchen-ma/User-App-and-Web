import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wishlist_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : _globalKey.currentState.hideCurrentSnackBar();
        _globalKey.currentState.showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? getTranslated('no_connection', _globalKey.currentContext) : getTranslated('connected', _globalKey.currentContext),
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<CartProvider>(context, listen: false).getCartData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false).initConfig(_globalKey).then((bool isSuccess) {
      if (isSuccess) {
        Timer(Duration(seconds: 1), () async {
          if(Provider.of<SplashProvider>(context, listen: false).configModel.maintenanceMode) {
            Navigator.pushNamedAndRemoveUntil(context, Routes.getMaintainRoute(), (route) => false);
          }else{
            if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
              Provider.of<AuthProvider>(context, listen: false).updateToken();
              await Provider.of<WishListProvider>(context, listen: false).initWishList(
                context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
              );
              Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, ResponsiveHelper.isMobile(context) ? AppConstants.languages.length > 1
                  ? Routes.getLanguageRoute('splash') : Routes.getOnBoardingRoute() : Routes.getMainRoute(), (route) => false);
            }
          }

        }

        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Color(0xFF174823),
      body: Center(
        child: Consumer<SplashProvider>(builder: (context, splash, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveHelper.isWeb() ? FadeInImage.assetNetwork(
                placeholder: Images.placeholder_rectangle, height: 165,
                image: splash.baseUrls != null ? 'assets/image/splashlogo.png' : '',
                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder_rectangle, height: 170),
              ) : Image.asset(Images.splashlogo, height: 170),
              SizedBox(height: 15),
              Text(
                ResponsiveHelper.isWeb() ? splash.configModel.restaurantName : AppConstants.APP_SLOGAN,
                style: rubikRegular.copyWith(color: Theme.of(context).primaryColorLight, fontSize: 15),
              ),
              SizedBox(height: 45),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )  
            ],
          );
        
        }),
      
      ),
    );
  }
}
