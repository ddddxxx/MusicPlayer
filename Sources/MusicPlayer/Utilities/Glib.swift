//
//  Glib.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(Linux)

import Foundation
import playerctl

func gproperty<T, R>(_ ptr: UnsafeMutablePointer<T>, name: String, transform: (UnsafeMutablePointer<GValue>) -> R) -> R {
    ptr.withMemoryRebound(to: GObject.self, capacity: 1) {
        var value = GValue()
        g_object_get_property($0, name, &value)
        return transform(&value)
    }
}

public class GRunLoop {
    
    public static var main: GRunLoop = GRunLoop(context: g_main_context_default()!)
    
    let loop: OpaquePointer /* GMainLoop* */
    
    public convenience init?() {
        guard let context = g_main_context_get_thread_default() else {
            return nil
        }
        self.init(context: context)
    }
    
    public convenience init(context: OpaquePointer /* GMainContext* */ ) {
        self.init(loop: g_main_loop_new(context, 0)!)
    }
    
    init(loop: OpaquePointer) {
        self.loop = loop
    }
    
    deinit {
        g_main_loop_unref(loop)
    }
}

extension GRunLoop {
    
    public var isRunning: Bool {
        g_main_loop_is_running(loop) != 0
    }
    
    public var context: OpaquePointer /* GMainContext* */ {
        g_main_loop_get_context(loop)!
    }
    
    public func getGMainLoop() -> OpaquePointer /* GMainLoop* */ {
        loop
    }
    
    public func run() {
        g_main_loop_run(loop)
    }
    
    public func quit() {
        g_main_loop_quit(loop)
    }
}

#endif
