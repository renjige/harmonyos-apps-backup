import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { VitalityRecord, UserProfile, MicroAction, VitalityNote, SavedActionItem, VitalityPlan, VitalityTopic, DimensionOption } from '../models/VitalityModels'
import { AppContextService } from './AppContextService'
const STORE = 'huoli_vitality_v1';
const KEY_RECORDS = 'records';
const KEY_PROFILE = 'profile';
const KEY_ACHIEVEMENTS = 'achievements';
const KEY_REMINDER_AGENT = 'reminder_agent_id';
const KEY_ACTIONS = 'micro_actions';
const KEY_PINS = 'pin_days';
const KEY_WEEKLY = 'weekly_notes';
const KEY_NOTES = 'vitality_notes';
const KEY_SAVED_ACTIONS = 'saved_actions';
const KEY_PLANS = 'vitality_plans';
const KEY_TOPICS = 'vitality_topics';
export class VitalityStore {
    private static pref: preferences.Preferences | null = null;
    private static cacheReady: boolean = false;
    private static initAttempted: boolean = false;
    private static recordsCache: VitalityRecord[] = [];
    private static actionsCache: MicroAction[] = [];
    private static notesCache: VitalityNote[] = [];
    private static savedActionsCache: SavedActionItem[] = [];
    private static plansCache: VitalityPlan[] = [];
    private static topicsCache: VitalityTopic[] = [];
    static async init(context: common.UIAbilityContext): Promise<void> {
    VitalityStore.initAttempted = true
    await VitalityStore.pickPreferences(context)
    VitalityStore.cacheReady = false
    await VitalityStore.hydrateCache()
  }

  static async ensureReady(): Promise<boolean> {
    const ctx = AppContextService.getContext()
    if (VitalityStore.pref === null && ctx !== null) {
      await VitalityStore.pickPreferences(ctx)
    }
    if (VitalityStore.pref !== null && !VitalityStore.cacheReady) {
      await VitalityStore.hydrateCache()
    }
    return VitalityStore.pref !== null
  }

  /** 每次展示工作台前从磁盘重读，避免内存缓存与 Preferences 不一致 */
  static async refreshCacheFromDisk(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (VitalityStore.pref === null && ctx !== null) {
      await VitalityStore.pickPreferences(ctx)
    }
    if (VitalityStore.pref === null) {
      return
    }
    VitalityStore.cacheReady = false
    await VitalityStore.hydrateCache()
  }

  private static prefKeys(): string[] {
    return [
      KEY_RECORDS, KEY_PROFILE, KEY_ACHIEVEMENTS, KEY_REMINDER_AGENT, KEY_ACTIONS,
      KEY_PINS, KEY_WEEKLY, KEY_NOTES, KEY_SAVED_ACTIONS, KEY_PLANS, KEY_TOPICS
    ]
  }

  private static async pickPreferences(context: common.UIAbilityContext): Promise<void> {
    let abilityPref: preferences.Preferences | null = null
    let appPref: preferences.Preferences | null = null
    try {
      abilityPref = await preferences.getPreferences(context, STORE)
    } catch {
      // ignore
    }
    try {
      appPref = await preferences.getPreferences(context.getApplicationContext(), STORE)
    } catch {
      // ignore
    }
    if (abilityPref === null && appPref === null) {
      VitalityStore.pref = null
      return
    }
    if (abilityPref === null) {
      VitalityStore.pref = appPref
      return
    }
    if (appPref === null) {
      VitalityStore.pref = abilityPref
      return
    }
    const abilityScore = await VitalityStore.scorePref(abilityPref)
    const appScore = await VitalityStore.scorePref(appPref)
    VitalityStore.pref = abilityPref
    if (appScore > abilityScore) {
      await VitalityStore.copyAllKeys(appPref, abilityPref)
    }
  }

  private static async scorePref(pref: preferences.Preferences): Promise<number> {
    let score = 0
    for (const key of VitalityStore.prefKeys()) {
      score += (await VitalityStore.readPrefString(pref, key)).length
    }
    return score
  }

  private static async readPrefString(pref: preferences.Preferences, key: string): Promise<string> {
    try {
      const v = await pref.get(key, '')
      return `${v}`
    } catch {
      return ''
    }
  }

  private static async copyAllKeys(from: preferences.Preferences, to: preferences.Preferences): Promise<void> {
    for (const key of VitalityStore.prefKeys()) {
      const value = await VitalityStore.readPrefString(from, key)
      if (value.length > 0) {
        await to.put(key, value)
      }
    }
    try {
      await to.flush()
    } catch {
      // ignore
    }
  }

  private static async openPreferences(context: common.UIAbilityContext): Promise<void> {
    await VitalityStore.pickPreferences(context)
  }

  private static async hydrateCache(): Promise<void> {
        const raw = await VitalityStore.getString(KEY_RECORDS, '');
        VitalityStore.recordsCache = VitalityStore.parseRecords(raw);
        VitalityStore.actionsCache = VitalityStore.parseActions(await VitalityStore.getString(KEY_ACTIONS, ''));
        VitalityStore.notesCache = VitalityStore.parseNotes(await VitalityStore.getString(KEY_NOTES, ''));
        VitalityStore.savedActionsCache = VitalityStore.parseSavedActions(await VitalityStore.getString(KEY_SAVED_ACTIONS, ''));
        VitalityStore.plansCache = VitalityStore.parsePlans(await VitalityStore.getString(KEY_PLANS, ''));
        VitalityStore.topicsCache = VitalityStore.parseTopics(await VitalityStore.getString(KEY_TOPICS, ''));
        VitalityStore.cacheReady = true;
    }
    private static async ensureCache(): Promise<void> {
        await VitalityStore.ensureReady();
        if (!VitalityStore.cacheReady) {
            await VitalityStore.hydrateCache();
        }
    }
    static async loadAll(): Promise<VitalityRecord[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.cloneRecords(VitalityStore.recordsCache);
    }
    static async recordForDate(dateKey: string): Promise<VitalityRecord | undefined> {
        const list = await VitalityStore.loadAll();
        for (const r of list) {
            if (r.dateKey === dateKey) {
                return r;
            }
        }
        return undefined;
    }
    static async todayRecord(): Promise<VitalityRecord | undefined> {
        const today = new Date();
        const y = today.getFullYear();
        const m = today.getMonth() + 1;
        const d = today.getDate();
        const ms = m < 10 ? `0${m}` : `${m}`;
        const ds = d < 10 ? `0${d}` : `${d}`;
        return VitalityStore.recordForDate(`${y}-${ms}-${ds}`);
    }
    static async saveRecord(record: VitalityRecord): Promise<void> {
        const list = await VitalityStore.loadAll();
        const next: VitalityRecord[] = [];
        let replaced = false;
        for (const r of list) {
            if (r.dateKey === record.dateKey) {
                next.push(record);
                replaced = true;
            }
            else {
                next.push(r);
            }
        }
        if (!replaced) {
            next.push(record);
        }
        next.sort((a, b) => b.dateKey.localeCompare(a.dateKey));
        await VitalityStore.persistRecords(next);
    }
    static async deleteRecord(dateKey: string): Promise<void> {
        const list = await VitalityStore.loadAll();
        const next: VitalityRecord[] = [];
        for (const r of list) {
            if (r.dateKey !== dateKey) {
                next.push(r);
            }
        }
        await VitalityStore.persistRecords(next);
        await VitalityStore.saveActionsForDate(dateKey, []);
        const pins = await VitalityStore.loadPins();
        const keep: string[] = [];
        for (const p of pins) {
            if (p !== dateKey) {
                keep.push(p);
            }
        }
        await VitalityStore.putString(KEY_PINS, keep.join(','));
    }
    static async recordsInRange(startKey: string, endKey: string): Promise<VitalityRecord[]> {
        const list = await VitalityStore.loadAll();
        const out: VitalityRecord[] = [];
        for (const r of list) {
            if (r.dateKey >= startKey && r.dateKey <= endKey && r.isComplete()) {
                out.push(r);
            }
        }
        return out;
    }
    static async loadProfile(): Promise<UserProfile> {
        const raw = await VitalityStore.getString(KEY_PROFILE, '');
        if (raw.length === 0) {
            return new UserProfile();
        }
        const parts = raw.split('\t');
        const p = new UserProfile();
        if (parts.length >= 1) {
            p.nickname = parts[0];
        }
        if (parts.length >= 2) {
            p.avatarKey = parts[1];
        }
        if (parts.length >= 3) {
            p.reminderHour = parseInt(parts[2], 10);
        }
        if (parts.length >= 4) {
            p.reminderMinute = parseInt(parts[3], 10);
        }
        if (parts.length >= 5) {
            p.reminderEnabled = parts[4] === '1';
        }
        if (parts.length >= 6 && parts[5].length > 0) {
            p.themeMode = parts[5];
        }
        if (parts.length >= 7 && parts[6].length > 0) {
            const g = parseInt(parts[6], 10);
            if (g >= 1 && g <= 7) {
                p.weeklyGoalDays = g;
            }
        }
        return p;
    }
    static async saveProfile(profile: UserProfile): Promise<void> {
        const enabled = profile.reminderEnabled ? '1' : '0';
        const goal = profile.weeklyGoalDays >= 1 && profile.weeklyGoalDays <= 7 ?
            profile.weeklyGoalDays : 5;
        const line = `${profile.nickname}\t${profile.avatarKey}\t${profile.reminderHour}\t${profile.reminderMinute}\t${enabled}\t${profile.themeMode}\t${goal}`;
        await VitalityStore.putString(KEY_PROFILE, line);
    }
    static async loadUnlockedAchievements(): Promise<string[]> {
        const raw = await VitalityStore.getString(KEY_ACHIEVEMENTS, '');
        if (raw.length === 0) {
            return [];
        }
        return raw.split(',');
    }
    static async unlockAchievement(id: string): Promise<void> {
        const list = await VitalityStore.loadUnlockedAchievements();
        for (const a of list) {
            if (a === id) {
                return;
            }
        }
        list.push(id);
        await VitalityStore.putString(KEY_ACHIEVEMENTS, list.join(','));
    }
    static async clearAllRecords(): Promise<void> {
        VitalityStore.recordsCache = [];
        VitalityStore.actionsCache = [];
        VitalityStore.notesCache = [];
        VitalityStore.savedActionsCache = [];
        VitalityStore.plansCache = [];
        await VitalityStore.putString(KEY_RECORDS, '');
        await VitalityStore.putString(KEY_ACHIEVEMENTS, '');
        await VitalityStore.putString(KEY_ACTIONS, '');
        await VitalityStore.putString(KEY_PINS, '');
        await VitalityStore.putString(KEY_WEEKLY, '');
        await VitalityStore.putString(KEY_NOTES, '');
        await VitalityStore.putString(KEY_SAVED_ACTIONS, '');
        await VitalityStore.putString(KEY_PLANS, '');
        await VitalityStore.putString(KEY_TOPICS, '');
        VitalityStore.topicsCache = [];
    }
    static async noteById(id: string): Promise<VitalityNote | undefined> {
        const list = await VitalityStore.loadNotes();
        for (const n of list) {
            if (n.id === id) {
                return n;
            }
        }
        return undefined;
    }
    static async deleteUserAction(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        const next: SavedActionItem[] = [];
        for (const a of VitalityStore.savedActionsCache) {
            if (a.id !== id) {
                next.push(a);
            }
        }
        VitalityStore.savedActionsCache = next;
        await VitalityStore.persistSavedActions(next);
    }
    static async deletePlan(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        const next: VitalityPlan[] = [];
        for (const p of VitalityStore.plansCache) {
            if (p.id !== id) {
                next.push(p);
            }
        }
        VitalityStore.plansCache = next;
        await VitalityStore.persistPlans(next);
    }
    static async loadTopics(): Promise<VitalityTopic[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.cloneTopics(VitalityStore.topicsCache);
    }
    static async saveTopic(topic: VitalityTopic): Promise<void> {
        await VitalityStore.ensureCache();
        const next: VitalityTopic[] = [];
        let replaced = false;
        for (const t of VitalityStore.topicsCache) {
            if (t.id === topic.id) {
                next.push(topic);
                replaced = true;
            }
            else {
                next.push(t);
            }
        }
        if (!replaced) {
            next.push(topic);
        }
        next.sort((a: VitalityTopic, b: VitalityTopic): number => b.updatedAt - a.updatedAt);
        VitalityStore.topicsCache = next;
        await VitalityStore.persistTopics(next);
    }
    static async deleteTopic(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        const next: VitalityTopic[] = [];
        for (const t of VitalityStore.topicsCache) {
            if (t.id !== id) {
                next.push(t);
            }
        }
        VitalityStore.topicsCache = next;
        await VitalityStore.persistTopics(next);
    }
    static async loadNotes(): Promise<VitalityNote[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.cloneNotes(VitalityStore.notesCache);
    }
    static async saveNote(note: VitalityNote): Promise<void> {
        await VitalityStore.ensureCache();
        const next: VitalityNote[] = [];
        let replaced = false;
        for (const n of VitalityStore.notesCache) {
            if (n.id === note.id) {
                next.push(note);
                replaced = true;
            }
            else {
                next.push(n);
            }
        }
        if (!replaced) {
            next.push(note);
        }
        next.sort((a, b) => b.createdAt - a.createdAt);
        VitalityStore.notesCache = next;
        await VitalityStore.persistNotes(next);
    }
    static async deleteNote(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        const next: VitalityNote[] = [];
        for (const n of VitalityStore.notesCache) {
            if (n.id !== id) {
                next.push(n);
            }
        }
        VitalityStore.notesCache = next;
        await VitalityStore.persistNotes(next);
    }
    static async toggleNoteFavorite(id: string): Promise<boolean> {
        await VitalityStore.ensureCache();
        let now = false;
        for (const n of VitalityStore.notesCache) {
            if (n.id === id) {
                n.favorite = !n.favorite;
                now = n.favorite;
            }
        }
        await VitalityStore.persistNotes(VitalityStore.notesCache);
        return now;
    }
    static async loadSavedActions(): Promise<SavedActionItem[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.cloneSavedActions(VitalityStore.savedActionsCache);
    }
    static async saveUserAction(item: SavedActionItem): Promise<void> {
        await VitalityStore.ensureCache();
        const next: SavedActionItem[] = [];
        let replaced = false;
        for (const a of VitalityStore.savedActionsCache) {
            if (a.id === item.id) {
                next.push(item);
                replaced = true;
            }
            else {
                next.push(a);
            }
        }
        if (!replaced) {
            next.push(item);
        }
        VitalityStore.savedActionsCache = next;
        await VitalityStore.persistSavedActions(next);
    }
    static async bumpActionUsage(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        for (const a of VitalityStore.savedActionsCache) {
            if (a.id === id) {
                a.usageCount++;
            }
        }
        await VitalityStore.persistSavedActions(VitalityStore.savedActionsCache);
    }
    static async loadPlans(): Promise<VitalityPlan[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.clonePlans(VitalityStore.plansCache);
    }
    static async savePlan(plan: VitalityPlan): Promise<void> {
        await VitalityStore.ensureCache();
        const stored = plan.copy();
        const next: VitalityPlan[] = [];
        let replaced = false;
        for (const p of VitalityStore.plansCache) {
            if (p.id === stored.id) {
                next.push(stored);
                replaced = true;
            }
            else {
                next.push(p);
            }
        }
        if (!replaced) {
            next.push(stored);
        }
        VitalityStore.plansCache = next;
        await VitalityStore.persistPlans(next);
    }
    static async favoriteCount(): Promise<number> {
        const pins = await VitalityStore.loadPins();
        const notes = await VitalityStore.loadNotes();
        let c = pins.length;
        for (const n of notes) {
            if (n.favorite) {
                c++;
            }
        }
        return c;
    }
    static async loadActions(): Promise<MicroAction[]> {
        await VitalityStore.ensureCache();
        return VitalityStore.cloneActions(VitalityStore.actionsCache);
    }
    static async actionsForDate(dateKey: string): Promise<MicroAction[]> {
        await VitalityStore.ensureCache();
        const out: MicroAction[] = [];
        for (const a of VitalityStore.actionsCache) {
            if (a.dateKey === dateKey) {
                out.push(VitalityStore.cloneAction(a));
            }
        }
        return out;
    }
    static async saveActionsForDate(dateKey: string, items: MicroAction[]): Promise<void> {
        await VitalityStore.ensureCache();
        const next: MicroAction[] = [];
        for (const a of VitalityStore.actionsCache) {
            if (a.dateKey !== dateKey) {
                next.push(a);
            }
        }
        for (const a of items) {
            next.push(a);
        }
        await VitalityStore.persistActions(next);
    }
    static async toggleAction(id: string): Promise<void> {
        await VitalityStore.ensureCache();
        for (const a of VitalityStore.actionsCache) {
            if (a.id === id) {
                a.done = !a.done;
            }
        }
        await VitalityStore.persistActions(VitalityStore.actionsCache);
    }
    static async doneActionCount(): Promise<number> {
        const all = await VitalityStore.loadActions();
        let n = 0;
        for (const a of all) {
            if (a.done) {
                n++;
            }
        }
        return n;
    }
    static async loadPins(): Promise<string[]> {
        const raw = await VitalityStore.getString(KEY_PINS, '');
        if (raw.length === 0) {
            return [];
        }
        return raw.split(',');
    }
    static async isPinned(dateKey: string): Promise<boolean> {
        const pins = await VitalityStore.loadPins();
        for (const p of pins) {
            if (p === dateKey) {
                return true;
            }
        }
        return false;
    }
    static async togglePin(dateKey: string): Promise<boolean> {
        const pins = await VitalityStore.loadPins();
        const next: string[] = [];
        let found = false;
        for (const p of pins) {
            if (p === dateKey) {
                found = true;
            }
            else {
                next.push(p);
            }
        }
        if (!found) {
            next.push(dateKey);
        }
        await VitalityStore.putString(KEY_PINS, next.join(','));
        return !found;
    }
    static async loadWeekly(weekKey: string): Promise<string> {
        const raw = await VitalityStore.getString(KEY_WEEKLY, '');
        if (raw.length === 0) {
            return '';
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const i = line.indexOf('\t');
            if (i > 0 && line.substring(0, i) === weekKey) {
                return line.substring(i + 1);
            }
        }
        return '';
    }
    static async saveWeekly(weekKey: string, text: string): Promise<void> {
        const raw = await VitalityStore.getString(KEY_WEEKLY, '');
        const lines = raw.length === 0 ? [] : raw.split('\n');
        const next: string[] = [];
        let replaced = false;
        const one = text.replace(/\t/g, ' ').replace(/\n/g, ' ');
        for (const line of lines) {
            if (line.length === 0) {
                continue;
            }
            const i = line.indexOf('\t');
            if (i > 0 && line.substring(0, i) === weekKey) {
                next.push(`${weekKey}\t${one}`);
                replaced = true;
            }
            else {
                next.push(line);
            }
        }
        if (!replaced) {
            next.push(`${weekKey}\t${one}`);
        }
        await VitalityStore.putString(KEY_WEEKLY, next.join('\n'));
    }
    static async hasAnyWeekly(): Promise<boolean> {
        const raw = await VitalityStore.getString(KEY_WEEKLY, '');
        return raw.length > 2;
    }
    private static async persistActions(items: MicroAction[]): Promise<void> {
        VitalityStore.actionsCache = VitalityStore.cloneActions(items);
        const lines: string[] = [];
        for (const a of items) {
            const done = a.done ? '1' : '0';
            const title = a.title.replace(/\t/g, ' ');
            const hint = a.hint.replace(/\t/g, ' ');
            lines.push([a.id, a.dateKey, title, hint, done].join('\t'));
        }
        await VitalityStore.putString(KEY_ACTIONS, lines.join('\n'));
    }
    private static parseActions(raw: string): MicroAction[] {
        const out: MicroAction[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length < 5) {
                continue;
            }
            const a = new MicroAction();
            a.id = parts[0];
            a.dateKey = parts[1];
            a.title = parts[2];
            a.hint = parts[3];
            a.done = parts[4] === '1';
            out.push(a);
        }
        return out;
    }
    static async saveReminderAgentId(id: number): Promise<void> {
        await VitalityStore.putString(KEY_REMINDER_AGENT, `${id}`);
    }
    static async loadReminderAgentId(): Promise<number> {
        const raw = await VitalityStore.getString(KEY_REMINDER_AGENT, '0');
        return parseInt(raw, 10);
    }
    static async exportText(): Promise<string> {
        const list = await VitalityStore.loadAll();
        const profile = await VitalityStore.loadProfile();
        const lines: string[] = [];
        lines.push('活力纪行 · 数据导出');
        lines.push(`昵称：${profile.nickname}`);
        lines.push(`导出时间：${new Date().toLocaleString()}`);
        lines.push('---');
        for (const r of list) {
            if (!r.isComplete()) {
                continue;
            }
            lines.push(`日期：${r.dateKey}`);
            lines.push(`  运动：${DimensionOption.labelFor('exercise', r.exerciseKey)} | 心情：${DimensionOption.labelFor('mood', r.moodKey)} | 精力：${DimensionOption.labelFor('energy', r.energyKey)}`);
            if (r.note.length > 0) {
                lines.push(`  备注：${r.note}`);
            }
            lines.push('');
        }
        return lines.join('\n');
    }
    private static async persistRecords(items: VitalityRecord[]): Promise<void> {
        VitalityStore.recordsCache = VitalityStore.cloneRecords(items);
        const lines: string[] = [];
        for (const r of items) {
            lines.push(VitalityStore.serialize(r));
        }
        await VitalityStore.putString(KEY_RECORDS, lines.join('\n'));
    }
    private static serialize(r: VitalityRecord): string {
        const note = r.note.replace(/\t/g, ' ').replace(/\n/g, ' ');
        const tags = r.tagKeys.replace(/\t/g, ' ').replace(/,/g, '|');
        return [r.dateKey, r.exerciseKey, r.moodKey, r.energyKey, note, `${r.timestamp}`, tags].join('\t');
    }
    private static parseRecords(raw: string): VitalityRecord[] {
        const out: VitalityRecord[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            if (line.length === 0) {
                continue;
            }
            const parts = line.split('\t');
            if (parts.length < 6) {
                continue;
            }
            const r = new VitalityRecord();
            r.dateKey = parts[0];
            r.exerciseKey = parts[1];
            r.moodKey = parts[2];
            r.energyKey = parts[3];
            r.note = parts[4];
            r.timestamp = parseInt(parts[5], 10);
            if (parts.length >= 7) {
                r.tagKeys = parts[6].replace(/\|/g, ',');
            }
            out.push(r);
        }
        out.sort((a, b) => b.dateKey.localeCompare(a.dateKey));
        return out;
    }
    private static cloneRecord(r: VitalityRecord): VitalityRecord {
        const c = new VitalityRecord();
        c.dateKey = r.dateKey;
        c.exerciseKey = r.exerciseKey;
        c.moodKey = r.moodKey;
        c.energyKey = r.energyKey;
        c.note = r.note;
        c.timestamp = r.timestamp;
        c.tagKeys = r.tagKeys;
        return c;
    }
    private static cloneRecords(list: VitalityRecord[]): VitalityRecord[] {
        const out: VitalityRecord[] = [];
        for (const r of list) {
            out.push(VitalityStore.cloneRecord(r));
        }
        return out;
    }
    private static cloneAction(a: MicroAction): MicroAction {
        const c = new MicroAction();
        c.id = a.id;
        c.dateKey = a.dateKey;
        c.title = a.title;
        c.hint = a.hint;
        c.done = a.done;
        return c;
    }
    private static cloneActions(list: MicroAction[]): MicroAction[] {
        const out: MicroAction[] = [];
        for (const a of list) {
            out.push(VitalityStore.cloneAction(a));
        }
        return out;
    }
    private static async persistNotes(items: VitalityNote[]): Promise<void> {
        const lines: string[] = [];
        for (const n of items) {
            const title = n.title.replace(/\t/g, ' ').replace(/\n/g, ' ');
            const body = n.body.replace(/\t/g, ' ').replace(/\n/g, ' ');
            const fav = n.favorite ? '1' : '0';
            const tags = n.tagKeys.replace(/\t/g, ' ').replace(/,/g, '|');
            const topics = n.topicIds.replace(/\t/g, ' ').replace(/,/g, '|');
            lines.push([n.id, title, body, n.dateKey, `${n.createdAt}`, fav, tags, topics].join('\t'));
        }
        await VitalityStore.putString(KEY_NOTES, lines.join('\n'));
    }
    private static parseNotes(raw: string): VitalityNote[] {
        const out: VitalityNote[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length < 5) {
                continue;
            }
            const n = new VitalityNote();
            n.id = parts[0];
            n.title = parts[1];
            n.body = parts[2];
            n.dateKey = parts[3];
            n.createdAt = parseInt(parts[4], 10);
            n.favorite = parts.length >= 6 && parts[5] === '1';
            if (parts.length >= 7) {
                n.tagKeys = parts[6].replace(/\|/g, ',');
            }
            if (parts.length >= 8) {
                n.topicIds = parts[7].replace(/\|/g, ',');
            }
            out.push(n);
        }
        out.sort((a, b) => b.createdAt - a.createdAt);
        return out;
    }
    private static cloneNote(n: VitalityNote): VitalityNote {
        const c = new VitalityNote();
        c.id = n.id;
        c.title = n.title;
        c.body = n.body;
        c.dateKey = n.dateKey;
        c.createdAt = n.createdAt;
        c.favorite = n.favorite;
        c.tagKeys = n.tagKeys;
        c.topicIds = n.topicIds;
        return c;
    }
    private static cloneNotes(list: VitalityNote[]): VitalityNote[] {
        const out: VitalityNote[] = [];
        for (const n of list) {
            out.push(VitalityStore.cloneNote(n));
        }
        return out;
    }
    private static async persistSavedActions(items: SavedActionItem[]): Promise<void> {
        const lines: string[] = [];
        for (const a of items) {
            const title = a.title.replace(/\t/g, ' ');
            const hint = a.hint.replace(/\t/g, ' ');
            lines.push([a.id, title, hint, a.category, a.source, `${a.usageCount}`].join('\t'));
        }
        await VitalityStore.putString(KEY_SAVED_ACTIONS, lines.join('\n'));
    }
    private static parseSavedActions(raw: string): SavedActionItem[] {
        const out: SavedActionItem[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length < 6) {
                continue;
            }
            const a = new SavedActionItem();
            a.id = parts[0];
            a.title = parts[1];
            a.hint = parts[2];
            a.category = parts[3];
            a.source = parts[4];
            a.usageCount = parseInt(parts[5], 10);
            out.push(a);
        }
        return out;
    }
    private static cloneSavedAction(a: SavedActionItem): SavedActionItem {
        const c = new SavedActionItem();
        c.id = a.id;
        c.title = a.title;
        c.hint = a.hint;
        c.category = a.category;
        c.source = a.source;
        c.usageCount = a.usageCount;
        return c;
    }
    private static cloneSavedActions(list: SavedActionItem[]): SavedActionItem[] {
        const out: SavedActionItem[] = [];
        for (const a of list) {
            out.push(VitalityStore.cloneSavedAction(a));
        }
        return out;
    }
    private static async persistPlans(items: VitalityPlan[]): Promise<void> {
        VitalityStore.plansCache = VitalityStore.clonePlans(items);
        const lines: string[] = [];
        for (const p of items) {
            const title = p.title.replace(/\t/g, ' ');
            lines.push([p.id, title, p.planType, `${p.targetValue}`, `${p.currentValue}`,
                p.startKey, p.endKey, p.status].join('\t'));
        }
        await VitalityStore.putString(KEY_PLANS, lines.join('\n'));
    }
    private static parsePlans(raw: string): VitalityPlan[] {
        const out: VitalityPlan[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length < 8) {
                continue;
            }
            const p = new VitalityPlan();
            p.id = parts[0];
            p.title = parts[1];
            p.planType = parts[2];
            p.targetValue = parseInt(parts[3], 10);
            p.currentValue = parseInt(parts[4], 10);
            p.startKey = parts[5];
            p.endKey = parts[6];
            p.status = parts[7];
            out.push(p);
        }
        return out;
    }
    private static clonePlan(p: VitalityPlan): VitalityPlan {
        const c = new VitalityPlan();
        c.id = p.id;
        c.title = p.title;
        c.planType = p.planType;
        c.targetValue = p.targetValue;
        c.currentValue = p.currentValue;
        c.startKey = p.startKey;
        c.endKey = p.endKey;
        c.status = p.status;
        return c;
    }
    private static clonePlans(list: VitalityPlan[]): VitalityPlan[] {
        const out: VitalityPlan[] = [];
        for (const p of list) {
            out.push(VitalityStore.clonePlan(p));
        }
        return out;
    }
    private static async persistTopics(items: VitalityTopic[]): Promise<void> {
        VitalityStore.topicsCache = VitalityStore.cloneTopics(items);
        const lines: string[] = [];
        for (const t of items) {
            const title = t.title.replace(/\t/g, ' ');
            const emoji = t.emoji.replace(/\t/g, ' ');
            lines.push([t.id, title, emoji, t.noteIds, t.recordKeys, `${t.createdAt}`, `${t.updatedAt}`].join('\t'));
        }
        await VitalityStore.putString(KEY_TOPICS, lines.join('\n'));
    }
    private static parseTopics(raw: string): VitalityTopic[] {
        const out: VitalityTopic[] = [];
        if (raw.length === 0) {
            return out;
        }
        const lines = raw.split('\n');
        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length < 7) {
                continue;
            }
            const t = new VitalityTopic();
            t.id = parts[0];
            t.title = parts[1];
            t.emoji = parts[2];
            t.noteIds = parts[3];
            t.recordKeys = parts[4];
            t.createdAt = parseInt(parts[5], 10);
            t.updatedAt = parseInt(parts[6], 10);
            out.push(t);
        }
        out.sort((a: VitalityTopic, b: VitalityTopic): number => b.updatedAt - a.updatedAt);
        return out;
    }
    private static cloneTopic(t: VitalityTopic): VitalityTopic {
        const c = new VitalityTopic();
        c.id = t.id;
        c.title = t.title;
        c.emoji = t.emoji;
        c.noteIds = t.noteIds;
        c.recordKeys = t.recordKeys;
        c.createdAt = t.createdAt;
        c.updatedAt = t.updatedAt;
        return c;
    }
    private static cloneTopics(list: VitalityTopic[]): VitalityTopic[] {
        const out: VitalityTopic[] = [];
        for (const t of list) {
            out.push(VitalityStore.cloneTopic(t));
        }
        return out;
    }
    static async exportJson(): Promise<string> {
        const lines: string[] = [];
        lines.push(await VitalityStore.exportText());
        lines.push('--- 纪行笔记 ---');
        const notes = await VitalityStore.loadNotes();
        for (const n of notes) {
            lines.push(`[${n.dateKey}] ${n.title}: ${n.body}`);
        }
        lines.push('--- 活力计划 ---');
        const plans = await VitalityStore.loadPlans();
        for (const p of plans) {
            lines.push(`${p.title}（${VitalityStore.planTypeLabel(p.planType)}）${p.currentValue}/${p.targetValue} · ${VitalityStore.planStatusLabel(p.status)}`);
        }
        lines.push('--- 活力专题 ---');
        const topics = await VitalityStore.loadTopics();
        for (const t of topics) {
            lines.push(`${t.emoji} ${t.title} · 记录${t.recordKeys.length > 0 ? t.recordKeys.split(',').length : 0} · 笔记${t.noteIds.length > 0 ? t.noteIds.split(',').length : 0}`);
        }
        return lines.join('\n');
    }
    private static planTypeLabel(type: string): string {
        if (type === 'checkin') {
            return '打卡';
        }
        if (type === 'prescription') {
            return '处方完成率';
        }
        return '自定义';
    }
    private static planStatusLabel(status: string): string {
        if (status === 'active') {
            return '进行中';
        }
        return '已完成';
    }
    private static async getString(key: string, fallback: string): Promise<string> {
        if (VitalityStore.pref === null) {
            return fallback;
        }
        try {
            const v = await VitalityStore.pref.get(key, fallback);
            return `${v}`;
        }
        catch {
            return fallback;
        }
    }
    private static async putString(key: string, value: string): Promise<void> {
        if (VitalityStore.pref === null) {
            return;
        }
        try {
            await VitalityStore.pref.put(key, value);
            await VitalityStore.pref.flush();
        }
        catch {
            // ignore
        }
    }
}
