//
//  OfflineManagerUtils.swift
//  location
//
//  Created by Patryk on 02/06/2020.
//

import Flutter
import Foundation
import Mapbox

class OfflineManagerUtils {
    static var activeDownloaders: [Int: OfflinePackDownloader] = [:]
    
    static func downloadRegion(
        definition: OfflineRegionDefinition,
        result: @escaping FlutterResult,
        registrar: FlutterPluginRegistrar,
        channelHandler: OfflineChannelHandler
    ) {
        // While the Android SDK generates a region ID in createOfflineRegion, the iOS
        // SDK does not have this feature. Therefore, we generate a region ID here.
        let id = Int.random(in: 0..<Int.max)
        let regionData = OfflineRegionData.fromOfflineRegionDefinition(definition, id: id)
        // Prepare downloader
        let downloader = OfflinePackDownloader(
            result: result,
            channelHandler: channelHandler,
            region: definition.toMGLTilePyramidOfflineRegion(),
            context: regionData.prepareContext(),
            regionId: regionData.id
        )
        // Save downloader so it does not get deallocated
        activeDownloaders[regionData.id] = downloader
        
        // Download region
        downloader.download()

        // Provide region with generated id
        result(regionData.toJsonString())
    }
    
    static func regionsList(result: @escaping FlutterResult) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let packs = offlineStorage.packs else {
            result("[]")
            return
        }
        let regionsArgs = packs.compactMap { pack -> [String: Any]? in
            guard let definition = pack.region as? MGLTilePyramidOfflineRegion,
                let regionArgs = OfflineRegionData.fromOfflineRegion(definition, context: pack.context),
                let jsonData = regionArgs.toJsonString().data(using: .utf8),
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
                let jsonDict = jsonObject as? [String: Any]
                else { return nil }
            return jsonDict
        }
        guard let regionsArgsJsonData = try? JSONSerialization.data(withJSONObject: regionsArgs),
            let regionsArgsJsonString = String(data: regionsArgsJsonData, encoding: .utf8)
            else {
                result(FlutterError(code: "RegionListError", message: nil, details: nil))
                return
        }
        result(regionsArgsJsonString)
    }
    
    static func deleteRegion(result: @escaping FlutterResult, id: Int) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let pacs = offlineStorage.packs else { return }
        let packToRemove = pacs.first(where: { pack -> Bool in
            let contextJsonObject = try? JSONSerialization.jsonObject(with: pack.context)
            let contextJsonDict = contextJsonObject as? [String: Any]
            if let regionId = contextJsonDict?["id"] as? Int {
                return regionId == id
            } else {
                return false
            }
        })
        if let packToRemoveUnwrapped = packToRemove {
            offlineStorage.removePack(packToRemoveUnwrapped) { error in
                if let error = error {
                    result(FlutterError(
                        code: "DeleteRegionError",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(nil)
                }
            }
        } else {
            result(FlutterError(
                code: "DeleteRegionError",
                message: "There is no region with given id to delete",
                details: nil
            ))
        }
    }
    
    /// Removes downloader from cache so it's memory can be deallocated
    static func releaseDownloader(id: Int) {
        activeDownloaders.removeValue(forKey: id)
    }
}
