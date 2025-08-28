package command_saturation_protocol;

import com.fs.starfarer.api.BaseModPlugin;
import com.fs.starfarer.api.Global;
import com.fs.starfarer.api.SettingsAPI;

/**
 * Minimal plugin that logs the effective settings values loaded by the game.
 * This does not change gameplay. It is only for visibility.
 */
public class ModPlugin extends BaseModPlugin {
    private boolean uiUpdated = false;

    @Override
    public void onApplicationLoad() throws Exception {
        // Log once on application load; settings are available at this point
        SettingsAPI settings = Global.getSettings();
        int maxBattleSize = settings.getInt("maxBattleSize");
        float smallerSideFraction = settings.getFloat("minFractionOfBattleSizeForSmallerSide");
        int maxShipsInFleet = settings.getInt("maxShipsInFleet");

        // Also read the mod's installed values directly (for display parity)
        int fileMaxBattleSize = maxBattleSize;
        float fileFraction = smallerSideFraction;
        int fileMaxShips = maxShipsInFleet;
        try {
            org.json.JSONObject modJson = settings.loadJSON("data/config/settings.json", "command_saturation_protocol");
            if (modJson != null) {
                if (modJson.has("maxBattleSize")) fileMaxBattleSize = modJson.getInt("maxBattleSize");
                if (modJson.has("minFractionOfBattleSizeForSmallerSide")) fileFraction = (float) modJson.getDouble("minFractionOfBattleSizeForSmallerSide");
                if (modJson.has("maxShipsInFleet")) fileMaxShips = modJson.getInt("maxShipsInFleet");
            }
        } catch (Throwable ignored) {}

        System.out.println(String.format(
                "[CSP] Loaded settings -> maxBattleSize=%d, minFractionOfBattleSizeForSmallerSide=%.3f, maxShipsInFleet=%d",
                maxBattleSize, smallerSideFraction, maxShipsInFleet
        ));

        // UI update is done in onGameLoad to ensure LunaLib is initialized
    }

    @Override
    public void onGameLoad(boolean newGame) {
        if (uiUpdated) return;
        uiUpdated = true;
        SettingsAPI settings = Global.getSettings();

        int fileMaxBattleSize = settings.getInt("maxBattleSize");
        float fileFraction = settings.getFloat("minFractionOfBattleSizeForSmallerSide");
        int fileMaxShips = settings.getInt("maxShipsInFleet");
        try {
            org.json.JSONObject modJson = settings.loadJSON("data/config/settings.json", "command_saturation_protocol");
            if (modJson != null) {
                if (modJson.has("maxBattleSize")) fileMaxBattleSize = modJson.getInt("maxBattleSize");
                if (modJson.has("minFractionOfBattleSizeForSmallerSide")) fileFraction = (float) modJson.getDouble("minFractionOfBattleSizeForSmallerSide");
                if (modJson.has("maxShipsInFleet")) fileMaxShips = modJson.getInt("maxShipsInFleet");
            }
        } catch (Throwable ignored) {}

        try {
            String modId = "command_saturation_protocol";
            Class<?> cls = Class.forName("lunalib.lunaSettings.LunaSettings");
            java.lang.reflect.Method setString = null;
            try { setString = cls.getMethod("setString", String.class, String.class, String.class); } catch (NoSuchMethodException ignored) {}
            if (setString != null) {
                setString.invoke(null, modId, "text_bs", String.valueOf(fileMaxBattleSize));
                setString.invoke(null, modId, "text_frac", String.format("%.3f", fileFraction));
                setString.invoke(null, modId, "text_ships", String.valueOf(fileMaxShips));
                System.out.println("[CSP] Updated LunaLib panel with installed settings.json values.");
            }
        } catch (Throwable ignored) {
        }
    }
}


