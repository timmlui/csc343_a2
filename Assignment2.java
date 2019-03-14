import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    private Connection connection;

    public Assignment2() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try {
            connection = DriverManager.getConnection(url, username, password);
        } catch (SQLException exception) {
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException exception) {
                return false;
            }
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        Statement stmt = null;
        String query =  "CREATE VIEW electionsAndCabinetsData AS" +
                        "SELECT e.id as e_id, e.e_type as type, e.e_date as election_year," +
                                "cab.id as cab_id, cab.start_date as cab_year," +
                                "e.previous_parliament_election_id as prev_p_eid," +
                                "e.previous_ep_election_id as prev_ep_eid" +
                        "FROM country c" +
                            "INNER JOIN election e ON c.id = e.country_id" +
                            "INNER JOIN cabinet cab ON e.id = cab.election_id" +
                        "WHERE c.name = " + countryName +
                        "ORDER BY election_year DESC" +
                        "" +
                        "SELECT DISTINCT e1.e_id, e1.cab_id" +
                        "FROM electionsAndCabinetsData e1" +
                            "INNER JOIN electionsAndCabinetsData e2 ON" +
                                "(CASE WHEN e1.type = 'Parliamentary election' THEN e1.prev_p_eid" +
                                    "WHEN e1.type = 'European Parliament' THEN e1.prev_ep_eid" +
                                "END) = e2.e_id" +
                        "WHERE e1.type = e2.type AND e2.cab_year > e2.election_year" +
                            "AND e2.cab_year < e1.election_year";

        List<Integer> elections;
        List<Integer> cabinets;
        ElectionCabinetResult result;
        
        try {
            stmt = connection.createStatement();
            ResultSet res = stmt.executeQuery(query);
            
            while (res.next()) {
                int election_id = res.getString("e_id");
                elections.add(election_id);
                int cabinet_id = res.getString("cab_id");
                cabinets.add(cabinet_id);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            res.close();
            stmt.close();
        }
        result = new ElectionCabinetResult(elections, cabinets);
        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        Statement stmt = null;
        String query = "";

        List<Integer> result = new ArrayList<Integer>();

        try {
            stmt = connection.createStatement();
            ResultSet res = stmt.executeQuery(query);
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            res.close();
            stmt.close();
        }
        return result;
    }

}

