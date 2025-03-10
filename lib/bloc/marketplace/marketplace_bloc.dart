import 'dart:async';

import 'package:breez/bloc/marketplace/vendor_model.dart';
import 'package:flutter/services.dart';
import "package:ini/ini.dart";
import 'package:rxdart/rxdart.dart';

class MarketplaceBloc {
  final _vendorController = BehaviorSubject<List<VendorModel>>();
  Stream<List<VendorModel>> get vendorsStream => _vendorController.stream;

  MarketplaceBloc() {
    initMarketplace();
  }

  Future initMarketplace() async {
    Config config = await _readConfig();
    String _vendorsConf = config.get('Marketplace Options', 'vendors');
    var _vendorData = _vendorsConf.split(",").toList();
    List<VendorModel> _vendorList = [];
    _vendorData.forEach((vendorOptions) {
      String _url = config.get(vendorOptions, 'url');
      String _displayName =
          config.get(vendorOptions, 'displayName') ?? vendorOptions;
      String _logo = config.get(vendorOptions, 'logo');
      bool _onlyShowLogo = config.get(vendorOptions, 'onlyShowLogo') == "true";
      String _endpointURI = config.get(vendorOptions, 'endpointURI');
      String _responseID = config.get(vendorOptions, 'responseID');
      VendorModel _vendorModel = VendorModel(
        _url,
        vendorOptions,
        _displayName,
        logo: _logo,
        onlyShowLogo: _onlyShowLogo,
        endpointURI: _endpointURI,
        responseID: _responseID,
      );
      _vendorList.add(_vendorModel);
    });
    _vendorController.add(_vendorList);
  }

  Future<Config> _readConfig() async {
    String lines = await rootBundle.loadString('conf/marketplace.conf');
    return Config.fromString(lines);
  }

  close() {
    _vendorController.close();
  }
}
