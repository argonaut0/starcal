import gleam/list
import gleeunit
import gleeunit/should
import simplifile
import starcal.{Param, Property, parse_content_line, to_content_lines}

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
  let assert Ok(s) = simplifile.read("test/case1.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> should.equal([
    Ok(Property("BEGIN", [], "VCALENDAR")),
    Ok(Property("VERSION", [], "2.0")),
    Ok(Property("PRODID", [], "-//ABC Corporation//NONSGML My Product//EN")),
    Ok(Property("BEGIN", [], "VJOURNAL")),
    Ok(Property("DTSTAMP", [], "19970324T120000Z")),
    Ok(Property("UID", [], "uid5@example.com")),
    Ok(Property("ORGANIZER", [], "mailto:jsmith@example.com")),
    Ok(Property("STATUS", [], "DRAFT")),
    Ok(Property("CLASS", [], "PUBLIC")),
    Ok(Property("CATEGORIES", [], "Project Report,XYZ,Weekly Meeting")),
    Ok(Property(
      "DESCRIPTION",
      [],
      "Project xyz Review Meeting Minutes\\nAgenda\\n1. Review of project version 1.0 requirements.\\n2. Definitionof project processes.\\n3. Review of project schedule.\\nParticipants: John Smith\\, Jane Doe\\, Jim Dandy\\n-It was decided that the requirements need to be signed off by product marketing.\\n-Project processes were accepted.\\n-Project schedule needs to account for scheduled holidays and employee vacation time. Check with HR for specific dates.\\n-New schedule will be distributed by Friday.\\n-Next weeks meeting is cancelled. No meeting until 3/23.",
    )),
    Ok(Property("END", [], "VJOURNAL")),
    Ok(Property("END", [], "VCALENDAR")),
  ])
}

pub fn parse_content_lines_2_test() {
  let assert Ok(s) = simplifile.read("test/case2.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> should.equal([
    Ok(Property("BEGIN", [], "VCALENDAR")),
    Ok(Property("VERSION", [], "2.0")),
    Ok(Property("PRODID", [], "-//ABC Corporation//NONSGML My Product//EN")),
    Ok(Property("BEGIN", [], "VTODO")),
    Ok(Property("DTSTAMP", [], "19980130T134500Z")),
    Ok(Property("SEQUENCE", [], "2")),
    Ok(Property("UID", [], "uid4@example.com")),
    Ok(Property("ORGANIZER", [], "mailto:unclesam@example.com")),
    Ok(Property(
      "ATTENDEE",
      [Param("PARTSTAT", ["ACCEPTED"])],
      "mailto:jqpublic@example.com",
    )),
    Ok(Property("DUE", [], "19980415T000000")),
    Ok(Property("STATUS", [], "NEEDS-ACTION")),
    Ok(Property("SUMMARY", [], "Submit Income Taxes")),
    Ok(Property("BEGIN", [], "VALARM")),
    Ok(Property("ACTION", [], "AUDIO")),
    Ok(Property("TRIGGER", [], "19980403T120000Z")),
    Ok(Property(
      "ATTACH",
      [Param("FMTTYPE", ["audio/basic"])],
      "http://example.com/pub/audio-files/ssbanner.aud",
    )),
    Ok(Property("REPEAT", [], "4")),
    Ok(Property("DURATION", [], "PT1H")),
    Ok(Property("END", [], "VALARM")),
    Ok(Property("END", [], "VTODO")),
    Ok(Property("END", [], "VCALENDAR")),
  ])
}

pub fn parse_content_lines_3_test() {
  let assert Ok(s) = simplifile.read("test/case3.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> should.equal([
    Ok(Property("BEGIN", [], "VCALENDAR")),
    Ok(Property("PRODID", [], "-//RDU Software//NONSGML HandCal//EN")),
    Ok(Property("VERSION", [], "2.0")),
    Ok(Property("BEGIN", [], "VTIMEZONE")),
    Ok(Property("TZID", [], "America/New_York")),
    Ok(Property("BEGIN", [], "STANDARD")),
    Ok(Property("DTSTART", [], "19981025T020000")),
    Ok(Property("TZOFFSETFROM", [], "-0400")),
    Ok(Property("TZOFFSETTO", [], "-0500")),
    Ok(Property("TZNAME", [], "EST")),
    Ok(Property("END", [], "STANDARD")),
    Ok(Property("BEGIN", [], "DAYLIGHT")),
    Ok(Property("DTSTART", [], "19990404T020000")),
    Ok(Property("TZOFFSETFROM", [], "-0500")),
    Ok(Property("TZOFFSETTO", [], "-0400")),
    Ok(Property("TZNAME", [], "EDT")),
    Ok(Property("END", [], "DAYLIGHT")),
    Ok(Property("END", [], "VTIMEZONE")),
    Ok(Property("BEGIN", [], "VEVENT")),
    Ok(Property("DTSTAMP", [], "19980309T231000Z")),
    Ok(Property("UID", [], "guid-1.example.com")),
    Ok(Property("ORGANIZER", [], "mailto:mrbig@example.com")),
    Ok(Property(
      "ATTENDEE",
      [
        Param("RSVP", ["TRUE"]),
        Param("ROLE", ["REQ-PARTICIPANT"]),
        Param("CUTYPE", ["GROUP"]),
      ],
      "mailto:employee-A@example.com",
    )),
    Ok(Property("DESCRIPTION", [], "Project XYZ Review Meeting")),
    Ok(Property("CATEGORIES", [], "MEETING")),
    Ok(Property("CLASS", [], "PUBLIC")),
    Ok(Property("CREATED", [], "19980309T130000Z")),
    Ok(Property("SUMMARY", [], "XYZ Project Review")),
    Ok(Property(
      "DTSTART",
      [Param("TZID", ["America/New_York"])],
      "19980312T083000",
    )),
    Ok(Property(
      "DTEND",
      [Param("TZID", ["America/New_York"])],
      "19980312T093000",
    )),
    Ok(Property("LOCATION", [], "1CP Conference Room 4350")),
    Ok(Property("END", [], "VEVENT")),
    Ok(Property("END", [], "VCALENDAR")),
  ])
}

pub fn parse_content_lines_4_test() {
  let assert Ok(s) = simplifile.read("test/case4.ical")
  s
  |> to_content_lines()
  |> list.map(parse_content_line)
  |> should.equal([
    Ok(Property("BEGIN", [], "VCALENDAR")),
    Ok(Property(
      "X-TESTSTARCAL",
      [Param("ABC", ["123", "456", "789"]), Param("DEF", ["QWE", "RTY", "UIO"])],
      "BASN$!LKJFJAO%U!P#MA<;',\"",
    )),
    Ok(Property("END", [], "VCALENDAR")),
  ])
}
