import XCTest
@testable import wa

final class LaunchAgentManagerTests: XCTestCase {
    func testPropertyListRunsTheAppAndRestartsOnlyAfterACrash() throws {
        let plist = LaunchAgentManager.propertyList(
            executableURL: URL(fileURLWithPath: "/opt/wa/bin/../bin/wa"),
            logDirectory: URL(fileURLWithPath: "/tmp/wa-logs")
        )

        XCTAssertEqual(plist["Label"] as? String, LaunchAgentManager.label)
        XCTAssertEqual(plist["ProgramArguments"] as? [String], ["/opt/wa/bin/wa", "app"])
        XCTAssertEqual(plist["KeepAlive"] as? [String: Bool], ["SuccessfulExit": false])
        XCTAssertEqual(plist["RunAtLoad"] as? Bool, true)
        XCTAssertEqual(plist["LimitLoadToSessionType"] as? String, "Aqua")
        XCTAssertEqual(plist["StandardErrorPath"] as? String, "/tmp/wa-logs/launchagent.err.log")
        XCTAssertNoThrow(try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0))
    }

    func testPIDIsReadFromTheTopLevelOfLaunchctlPrint() {
        let description = """
        gui/501/local.wa.wallpaper-manager = {
        \tactive count = 1
        \tstate = running
        \tpid = 4242
        \tendpoints = {
        \t\tpid = 1
        \t}
        }
        """

        XCTAssertEqual(LaunchAgentManager.pid(fromServiceDescription: description), 4242)
    }

    func testPIDIsNilWhenTheAgentIsLoadedButNotRunning() {
        let description = """
        gui/501/local.wa.wallpaper-manager = {
        \tstate = not running
        \tlast exit code = 0
        }
        """

        XCTAssertNil(LaunchAgentManager.pid(fromServiceDescription: description))
    }
}
