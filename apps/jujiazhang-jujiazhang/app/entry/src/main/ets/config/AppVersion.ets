/** 与 AppScope/app.json5 保持同步；运行时优先读 AppStorage appVersionName（安装包真实版本） */
export class AppVersion {
  static readonly NAME: string = '1.7.0'
  static readonly CODE: number = 1000010

  static displayName(): string {
    const runtime = AppStorage.get<string>('appVersionName') ?? ''
    return runtime.length > 0 ? runtime : AppVersion.NAME
  }
}
