//
//  AppDelegate.swift
//  newfile
//
//  Created by Ashutosh on 07/07/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let target = urls.first else {
            NSApp.terminate(nil)
            return
        }

        let folder = directory(for: target)
        if let newFile = createNewFile(in: folder) {
            NSWorkspace.shared.activateFileViewerSelecting([newFile])
        }

        NSApp.terminate(nil)
    }

    private func directory(for url: URL) -> URL {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue ? url : url.deletingLastPathComponent()
    }

    private func createNewFile(in folder: URL) -> URL? {
        var name = "untitled.txt"
        var fileURL = folder.appendingPathComponent(name)
        var counter = 2

        while FileManager.default.fileExists(atPath: fileURL.path) {
            name = "untitled \(counter).txt"
            fileURL = folder.appendingPathComponent(name)
            counter += 1
        }

        let created = FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        return created ? fileURL : nil
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}


