export class ApiResponse<T> {
  code: number = 0
  message: string = ''
  data: T | undefined = undefined
}

export class LoginRequest {
  username: string = ''
  password: string = ''
  tenantId: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)},"password":${JSON.stringify(this.password)},"tenantId":${JSON.stringify(this.tenantId)}}`
  }
}

export class RegisterRequest {
  username: string = ''
  password: string = ''
  realName: string = ''
  phone: string = ''
  inviteCode: string = ''
  tenantId: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)},"password":${JSON.stringify(this.password)},"realName":${JSON.stringify(this.realName)},"phone":${JSON.stringify(this.phone)},"inviteCode":${JSON.stringify(this.inviteCode)},"tenantId":${JSON.stringify(this.tenantId)}}`
  }
}

export class LoginResponse {
  accessToken: string = ''
}

export class EmptyPayload {
}
