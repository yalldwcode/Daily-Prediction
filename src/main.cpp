#include <Geode/Geode.hpp>
#include <Geode/loader/ModEvent.hpp>
#include <imes.luauapi/include/LuauAPI.hpp>

using namespace geode::prelude;
namespace lua = imes::luauapi;

$on_mod(Loaded) {
    auto result = lua::runFile(Mod::get()->getResourcesDir(), "Main.luau");
    if (result.isErr()) {
        log::error("Daily Prediction script failed: {}", result.unwrapErr());
    }
}
