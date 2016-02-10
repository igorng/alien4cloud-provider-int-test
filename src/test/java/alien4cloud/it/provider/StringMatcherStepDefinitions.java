package alien4cloud.it.provider;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import lombok.extern.slf4j.Slf4j;

import org.junit.Assert;

import alien4cloud.it.Context;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;

@Slf4j
public class StringMatcherStepDefinitions {

    private static final Pattern MATCHER_PATTERN = Pattern.compile(".*(\\$\\{.+\\}).*");

    @Given("^I expand the string \"(.*?)\" and store it as \"(.*?)\" in the context$")
    public void i_expand_the_string_and_store_it_as_in_the_context(String stringToExpand, String key) throws Throwable {
        String expandedString = expandString(stringToExpand);
        Context.getInstance().registerStringContent(key, expandedString);
    }

    /**
     * All stuff that match ${someKey} will be replaced be the map entry which key is 'someKey'. The map is a map of string stored in the context.
     */
    private String expandString(String stringToExpand) {
        Matcher m = MATCHER_PATTERN.matcher(stringToExpand);
        while (m.matches()) {
            String foundKey = m.group(1);
            String mapKey = foundKey.substring(2, foundKey.length() - 1);
            String replaceValue = Context.getInstance().getRegisteredStringContent(mapKey);
            if (replaceValue == null) {
                Assert.fail(String.format("No key <%s> found in the registered strings map", mapKey));
            }
            stringToExpand = stringToExpand.substring(0, stringToExpand.indexOf(foundKey)) + replaceValue
                    + stringToExpand.substring(stringToExpand.indexOf(foundKey) + foundKey.length());
            m = MATCHER_PATTERN.matcher(stringToExpand);
        }
        return stringToExpand;
    }

    /**
     * Here we test that the regex sequence is respected : this means that the lines must match in the given order (even if we have other lines between them).
     */
    @Then("^the registered string \"(.*?)\" lines should match the following regex sequence$")
    public void the_registered_string_lines_should_match_the_following_regexps_sequence(String key, List<String> rows) throws Throwable {
        String content = Context.getInstance().getRegisteredStringContent(key);
        Iterator<String> regexIterator = rows.iterator();

        StringReader stringReader = new StringReader(content);
        BufferedReader bufferedReader = new BufferedReader(stringReader);
        String line = bufferedReader.readLine();
        String currentRegexp = regexIterator.next();
        boolean lastRegexMatched = false;
        while (line != null) {
            String expandedRegexp = expandString(currentRegexp);
            if (line.matches(expandedRegexp)) {
                lastRegexMatched = true;
                if (regexIterator.hasNext()) {
                    currentRegexp = regexIterator.next();
                } else {
                    // all regexp have been matched
                    break;
                }
            } else {
                lastRegexMatched = false;
            }
            line = bufferedReader.readLine();
        }
        if (regexIterator.hasNext() || !lastRegexMatched) {
            // this means that some regexp have not been matched
            Assert.fail("Some regex have not been matched, the sequence didn't match");
        }
    }

    /**
     * The first line of the table is a regex that contains capturing groups. The captured values are stored in the context using the keys that are found in the
     * other lines.
     */
    @Then("^I can catch the following groups in one line of the registered string \"(.*?)\" and store them as registered strings$")
    public void i_can_catch_the_following_groups_in_one_line_of_the_registered_string_and_store_them_as_registered_strings(String key, List<String> rows)
            throws Throwable {
        String regex = expandString(rows.get(0));
        Pattern pattern = Pattern.compile(regex);
        String content = Context.getInstance().getRegisteredStringContent(key);
        StringReader stringReader = new StringReader(content);
        BufferedReader bufferedReader = new BufferedReader(stringReader);
        String line = bufferedReader.readLine();
        boolean found = false;
        while (line != null) {
            Matcher matcher = pattern.matcher(line);
            if (matcher.matches()) {
                // ok the line matches the pattern
                Assert.assertEquals("Not the same number of groups than expected, please review test ...", rows.size() - 1, matcher.groupCount());
                for (int i = 1; i <= matcher.groupCount(); i++) {
                    String catchedValue = matcher.group(i);
                    String catchedKey = rows.get(i);
                    Context.getInstance().registerStringContent(catchedKey, catchedValue);
                }
                found = true;
                break;
            }
            line = bufferedReader.readLine();
        }
        if (!found) {
            Assert.fail(String.format("The line matching <%s> can not be found", regex));
        }
    }

    @Then("^the registered string \"(.*?)\" lines should match the following regex only (\\d+) time$")
    public void the_registered_string_lines_should_match_the_following_regex_only_time(String key, int expectedCount, List<String> regexps) throws Throwable {
        String content = Context.getInstance().getRegisteredStringContent(key);
        for (String regex : regexps) {
            Pattern pattern = Pattern.compile(regex);
            int matchCount = matchCount(content, pattern);
            Assert.assertEquals(String.format("The regexp <%s> doen't match the expected time onto : \n%s", pattern.pattern(), content), expectedCount,
                    matchCount);
        }
    }

    private int matchCount(String content, Pattern pattern) throws IOException {
        StringReader stringReader = new StringReader(content);
        BufferedReader bufferedReader = new BufferedReader(stringReader);
        String line = bufferedReader.readLine();
        int matchCount = 0;
        while (line != null) {
            Matcher matcher = pattern.matcher(line);
            if (matcher.matches()) {
                matchCount++;
            }
            line = bufferedReader.readLine();
        }
        return matchCount;
    }

    @Then("^the following expanded regex should be found in the registered string \"(.*?)\"$")
    public void the_following_expanded_regex_should_be_found_in_the_registered_string(String key, List<String> rows) throws Throwable {
        String content = Context.getInstance().getRegisteredStringContent(key);
        for (String row : rows) {
            String regex = expandString(row);
            Pattern p = Pattern.compile(regex, Pattern.MULTILINE);
            Matcher m = p.matcher(content);
            if (!m.find()) {
                Assert.fail(String.format("The regexp <%s> can not be found in the string \n%s", regex, content));
            }
        }
    }

}
