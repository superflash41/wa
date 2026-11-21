import XCTest
@testable import wa

final class ProcessRecordTests: XCTestCase {
    func testContentsRoundTrip() {
        let record = ProcessRecord(pid: 4242, startTime: 1_795_282_335_654_228)

        XCTAssertEqual(ProcessRecord(contents: record.contents), record)
    }

    func testLegacyPIDOnlyFileIsRejected() {
        XCTAssertNil(ProcessRecord(contents: "4242\n"))
    }

    func testLiveRecordIdentifiesTheCurrentProcess() throws {
        let record = try XCTUnwrap(ProcessRecord.live(pid: getpid()))

        XCTAssertEqual(record.pid, getpid())
        XCTAssertEqual(ProcessRecord.live(pid: getpid()), record)
    }

    func testLiveRecordIsNilAfterTheProcessExits() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/true")
        try process.run()
        process.waitUntilExit()

        XCTAssertNil(ProcessRecord.live(pid: process.processIdentifier))
    }

    func testRecordWithADifferentStartTimeDoesNotMatch() throws {
        let live = try XCTUnwrap(ProcessRecord.live(pid: getpid()))
        let stale = ProcessRecord(pid: live.pid, startTime: live.startTime - 1)

        XCTAssertNotEqual(stale, live)
    }
}
