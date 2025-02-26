import gleam/list
import gleeunit
import gleeunit/should
import simplifile as sf
import starcal.{
  Param, Property, parse_content_line, serialize_properties, to_content_lines,
}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn to_content_lines_test() {
  "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nEND:VCALENDAR\r\n"
  |> to_content_lines()
  |> should.equal(["BEGIN:VCALENDAR", "VERSION:2.0", "END:VCALENDAR"])

  "BEGIN:VCALENDAR\r\nDESCRIPTION:This is a long description\r\n  that should be split in\r\n to multiple lines\r\nEND:VCALENDAR\r\n"
  |> to_content_lines()
  |> should.equal([
    "BEGIN:VCALENDAR",
    "DESCRIPTION:This is a long description that should be split into multiple lines",
    "END:VCALENDAR",
  ])
}

pub fn parse_content_lines_test() {
  let expected = [
    Property("BEGIN", [], "VCALENDAR"),
    Property("VERSION", [], "2.0"),
    Property("PRODID", [], "-//ABC Corporation//NONSGML My Product//EN"),
    Property("BEGIN", [], "VJOURNAL"),
    Property("DTSTAMP", [], "19970324T120000Z"),
    Property("UID", [], "uid5@example.com"),
    Property("ORGANIZER", [], "mailto:jsmith@example.com"),
    Property("STATUS", [], "DRAFT"),
    Property("CLASS", [], "PUBLIC"),
    Property("CATEGORIES", [], "Project Report,XYZ,Weekly Meeting"),
    Property(
      "DESCRIPTION",
      [],
      "Project xyz Review Meeting Minutes\\nAgenda\\n1. Review of project version 1.0 requirements.\\n2. Definition of project processes.\\n3. Review of project schedule.\\nParticipants: John Smith\\, Jane Doe\\, Jim Dandy\\n-It was decided that the requirements need to be signed off by product marketing.\\n-Project processes were accepted.\\n-Project schedule needs to account for scheduled holidays and employee vacation time. Check with HR for specific dates.\\n-New schedule will be distributed by Friday.\\n-Next weeks meeting is cancelled. No meeting until 3/23.",
    ),
    Property("END", [], "VJOURNAL"),
    Property("END", [], "VCALENDAR"),
  ]
  let assert Ok(s) = sf.read("test/case1.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> list.zip(list.map(expected, Ok(_)))
  |> list.each(fn(x) {
    let #(a, b) = x
    should.equal(a, b)
  })

  expected
  |> serialize_properties
  |> should.equal(s)
}

pub fn parse_content_lines_2_test() {
  let expected = [
    Property("BEGIN", [], "VCALENDAR"),
    Property("VERSION", [], "2.0"),
    Property("PRODID", [], "-//ABC Corporation//NONSGML My Product//EN"),
    Property("BEGIN", [], "VTODO"),
    Property("DTSTAMP", [], "19980130T134500Z"),
    Property("SEQUENCE", [], "2"),
    Property("UID", [], "uid4@example.com"),
    Property("ORGANIZER", [], "mailto:unclesam@example.com"),
    Property(
      "ATTENDEE",
      [Param("PARTSTAT", ["ACCEPTED"])],
      "mailto:jqpublic@example.com",
    ),
    Property("DUE", [], "19980415T000000"),
    Property("STATUS", [], "NEEDS-ACTION"),
    Property("SUMMARY", [], "Submit Income Taxes"),
    Property("BEGIN", [], "VALARM"),
    Property("ACTION", [], "AUDIO"),
    Property("TRIGGER", [], "19980403T120000Z"),
    Property(
      "ATTACH",
      [Param("FMTTYPE", ["audio/basic"])],
      "http://example.com/pub/audio-files/ssbanner.aud",
    ),
    Property("REPEAT", [], "4"),
    Property("DURATION", [], "PT1H"),
    Property("END", [], "VALARM"),
    Property("END", [], "VTODO"),
    Property("END", [], "VCALENDAR"),
  ]
  let assert Ok(s) = sf.read("test/case2.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> list.zip(list.map(expected, Ok(_)))
  |> list.each(fn(x) {
    let #(a, b) = x
    should.equal(a, b)
  })
}

pub fn parse_content_lines_3_test() {
  let expected = [
    Property("BEGIN", [], "VCALENDAR"),
    Property("PRODID", [], "-//RDU Software//NONSGML HandCal//EN"),
    Property("VERSION", [], "2.0"),
    Property("BEGIN", [], "VTIMEZONE"),
    Property("TZID", [], "America/New_York"),
    Property("BEGIN", [], "STANDARD"),
    Property("DTSTART", [], "19981025T020000"),
    Property("TZOFFSETFROM", [], "-0400"),
    Property("TZOFFSETTO", [], "-0500"),
    Property("TZNAME", [], "EST"),
    Property("END", [], "STANDARD"),
    Property("BEGIN", [], "DAYLIGHT"),
    Property("DTSTART", [], "19990404T020000"),
    Property("TZOFFSETFROM", [], "-0500"),
    Property("TZOFFSETTO", [], "-0400"),
    Property("TZNAME", [], "EDT"),
    Property("END", [], "DAYLIGHT"),
    Property("END", [], "VTIMEZONE"),
    Property("BEGIN", [], "VEVENT"),
    Property("DTSTAMP", [], "19980309T231000Z"),
    Property("UID", [], "guid-1.example.com"),
    Property("ORGANIZER", [], "mailto:mrbig@example.com"),
    Property(
      "ATTENDEE",
      [
        Param("RSVP", ["TRUE"]),
        Param("ROLE", ["REQ-PARTICIPANT"]),
        Param("CUTYPE", ["GROUP"]),
      ],
      "mailto:employee-A@example.com",
    ),
    Property("DESCRIPTION", [], "Project XYZ Review Meeting"),
    Property("CATEGORIES", [], "MEETING"),
    Property("CLASS", [], "PUBLIC"),
    Property("CREATED", [], "19980309T130000Z"),
    Property("SUMMARY", [], "XYZ Project Review"),
    Property(
      "DTSTART",
      [Param("TZID", ["America/New_York"])],
      "19980312T083000",
    ),
    Property("DTEND", [Param("TZID", ["America/New_York"])], "19980312T093000"),
    Property("LOCATION", [], "1CP Conference Room 4350"),
    Property("END", [], "VEVENT"),
    Property("END", [], "VCALENDAR"),
  ]
  let assert Ok(s) = sf.read("test/case3.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> list.zip(list.map(expected, Ok(_)))
  |> list.each(fn(x) {
    let #(a, b) = x
    should.equal(a, b)
  })
}

pub fn parse_content_lines_4_test() {
  let expected = [
    Property("BEGIN", [], "VCALENDAR"),
    Property(
      "X-TESTSTARCAL",
      [Param("ABC", ["123", "456", "789"]), Param("DEF", ["QWE", "RTY", "UIO"])],
      "BASN$!LKJFJAO%U!P#MA<;',\"",
    ),
    Property("END", [], "VCALENDAR"),
  ]
  let assert Ok(s) = sf.read("test/case4.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> list.zip(list.map(expected, Ok(_)))
  |> list.each(fn(x) {
    let #(a, b) = x
    should.equal(a, b)
  })
}
