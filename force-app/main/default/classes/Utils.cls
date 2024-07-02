public with sharing class Utils {

	public static String toProperCase(String value) {
		value = value.toLowerCase();
		List<String> pieces = new List<String>();
		for(String s : value.split(' ')) {
			s = s.capitalize();
			pieces.add(s);
        }
		return String.join(pieces, ' ');
	}
}