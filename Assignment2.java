import java.sql.*;
import java.util.ArrayList;
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

    public Assignment2() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        // System.out.println("Hello");
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
        String query =  "CREATE VIEW electionsAndCabinetsData AS " +
                        "SELECT e.id as e_id, e.e_type as type, e.e_date as election_year, " +
                                "cab.id as cab_id, cab.start_date as cab_year, " +
                                "e.previous_parliament_election_id as prev_p_eid, " +
                                "e.previous_ep_election_id as prev_ep_eid " +
                        "FROM country c " +
                            "INNER JOIN election e ON c.id = e.country_id " +
                            "INNER JOIN cabinet cab ON e.id = cab.election_id " +
                        "WHERE c.name = " + countryName + " " +
                        "ORDER BY election_year DESC " +
                        "" +
                        "SELECT e1.e_id, e1.cab_id " +
                        "FROM electionsAndCabinetsData e1 " +
                            "INNER JOIN electionsAndCabinetsData e2 ON " +
                                "(CASE WHEN e1.type = 'Parliamentary election' THEN e1.prev_p_eid " +
                                    "WHEN e1.type = 'European Parliament' THEN e1.prev_ep_eid " +
                                "END) = e2.e_id " +
                        "WHERE e1.type = e2.type AND e2.cab_year > e2.election_year " +
                            "AND e2.cab_year < e1.election_year";

        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();
        
        try {
            Statement stmt = connection.createStatement();
            ResultSet res = stmt.executeQuery(query);
            
            while (res.next()) {
                int election_id = res.getInt("e_id");
                elections.add(election_id);
                int cabinet_id = res.getInt("cab_id");
                cabinets.add(cabinet_id);
            }
            res.close();
            stmt.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {

        List<Integer> result = new ArrayList<Integer>();
        String description = new String("");
        String comment = new String("");

        String query1 = "SELECT description, comment " +
                        "FROM politician_president " +
                        "WHERE id = " + politicianName;
        
        String query2 = "SELECT id, description, comment " +
                        "FROM politician_president " +
                        "WHERE id <> " + politicianName;

        try {
            Statement stmt = connection.createStatement();
            ResultSet res = stmt.executeQuery(query1);

            // description and comment of specified president
            while(res.next()) {
                description = res.getString("description");
                comment = res.getString("comment");
            }

            Statement stmt2 = connection.createStatement();
            ResultSet res2 = stmt2.executeQuery(query2);

            // descriptions and comments of all the other presidents
            while(res2.next()) {
                String otherDescription = res2.getString("description");
                String otherComment = res2.getString("comment");

                double similarity = similarity(description + " " + comment, 
                                                otherDescription + " " + otherComment);
                double similarity2 = similarity(comment + " " + description,
                                                 otherComment + " " + otherDescription);

                if (similarity >= threshold || similarity2 >= threshold) {
                    int id = res2.getInt("id");
                    result.add(id);
                }
            }
            res.close();
            stmt.close();
            res2.close();
            stmt2.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return result;
    }

}

